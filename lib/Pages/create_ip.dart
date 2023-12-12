import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:is_lock_screen2/is_lock_screen2.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photouploader/Models/group.dart';
import 'package:photouploader/Pages/askpin.dart';
import 'package:photouploader/Pages/editimage.dart';
import 'package:photouploader/Pages/menu.dart';
import 'package:photouploader/Widgets/littlephotos.dart';
import 'package:photouploader/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePage2 extends StatefulWidget {
  const CreatePage2({super.key, required this.lock});
  final bool lock;

  @override
  State<CreatePage2> createState() => _CreatePage2State();
}

class _CreatePage2State extends State<CreatePage2> with WidgetsBindingObserver {
  final Location location = Location();
  LocationData? _location;
  bool isEditDescrition = false;
  String description = '';
  int rotation = 0;
  XFile? imagePickerXFile;
  Uint8List? imageData;
  List<Photo> photosGroup = [];
  bool locationPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    doLock = widget.lock;
    //lastAppLifecycleStateTime = DateTime.now();
    doAskPermitions().then((value) {
      if (!locationPermission) {
        printLog('location permission not granted');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission not granted')));
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      bool? isLockScreenWasOnDevice = await isLockScreen();
      printLog('app inactive, is lock screen: ${await isLockScreen()}');
      if (isLockScreenWasOnDevice != null && isLockScreenWasOnDevice) {
        setState(() {
          doLock = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    printLog('[CreatePage2 build with doLock: $doLock]');
    return doLock
        ? AskPinCodePage(
            onPinCodeEntered: () {
              setState(() {});
            },
          )
        : Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NormalModePage()));
                },
              ),
              backgroundColor: Colors.grey[300],
              title: const Text('Создание фотографии'),
              centerTitle: true,
              actions: [
                IconButton(
                    color: locationPermission ? Colors.green : Colors.red,
                    icon: const Icon(Icons.location_on),
                    onPressed: locationPermission
                        ? () {}
                        : () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title:
                                          const Text('Отсутствует разрешение!'),
                                      content: const Text(
                                          'Необходимо включить в настройках разрешение на использование местоположения.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('ОК'))
                                      ],
                                    ));
                          })
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditDescrition) ...[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        enabled: photosGroup.isEmpty,
                        controller: TextEditingController(text: description),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Описание для группы фотографий',
                        ),
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditDescrition = !isEditDescrition;
                        });
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Сохранить'),
                    )
                  ] else if (photosGroup.isEmpty && imageData == null) ...[
                    TextButton.icon(
                        onPressed: photosGroup.isEmpty
                            ? () {
                                setState(() {
                                  isEditDescrition = !isEditDescrition;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.edit),
                        label: const Text('Добавить/Изменить описание группы'))
                  ],
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Описание группы: $description',
                    ),
                  ),
                  if (photosGroup.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: littleGroupPhotos(photosGroup),
                    ),
                    TextButton.icon(
                        onPressed: () async {
                          printLog('[Saving group of images]');
                          int nowTime = DateTime.now().microsecondsSinceEpoch;
                          List<List> group = [];
                          String basePath =
                              (await getApplicationSupportDirectory()).path;
                          for (var i = 0; i < photosGroup.length; i++) {
                            printLog(
                                '[generating path for storing image [$i]]');
                            String path = '$basePath/$nowTime-$i.jpg';
                            printLog('[path for storing this image]: $path');
                            File(path).writeAsBytesSync(photosGroup[i].data!,
                                flush: true);
                            group.add([
                              i.toString(),
                              photosGroup[i].lat.toString(),
                              photosGroup[i].long.toString()
                            ]);
                          }
                          printLog('[adding to notUploaded list]');
                          notUploaded.add([
                            nowTime.toString(),
                            description,
                            jsonEncode(group)
                          ]);
                          printLog('added: ${notUploaded.last}');
                          printLog(
                              '[saving notUploaded list to sharedPreferences]');
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          sharedPreferences.setString(
                              'notUploaded', jsonEncode(notUploaded));
                          photosGroup.clear();
                          description = '';
                          setState(() {});
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text('Сохранить группу'))
                  ],
                  if (imageData != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.memory(
                          imageData!,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                    TextButton.icon(
                        onPressed: () async {
                          try {
                            printLog('[adding image to group]');
                            /*
                            printLog(
                                '[generating path for storing this image]');
                            String path =
                                (await getApplicationSupportDirectory()).path;
                            path +=
                                '/${DateTime.now().microsecondsSinceEpoch}-${photosGroup.length}.jpg';
                            printLog('[path for storing this image]: $path');
                            File(path).writeAsBytesSync(imageData!, flush: true);
                            */
                            setState(() {
                              photosGroup.add(Photo(
                                  long: _location!.longitude,
                                  lat: _location!.latitude,
                                  //path: path,
                                  data: imageData));
                              imageData = null;
                            });
                          } catch (e) {
                            printLog(e);
                          }
                        },
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Добавить в группу'))
                  ],
                ],
              ),
            ),
            floatingActionButton: !locationPermission
                ? null
                : FloatingActionButton(
                    onPressed: () async {
                      _location = await location.getLocation();
                      getPhoto();
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
          );
  }

  getPhoto() {
    ImagePicker().pickImage(source: ImageSource.camera).then((value) {
      if (value != null) {
        Navigator.of(context)
            .push<Uint8List>(MaterialPageRoute(
                builder: (context) => EditImagePage(
                        pathFromPicker: value.path,
                        description: description,
                        coords: [
                          _location!.longitude ?? 0,
                          _location!.latitude ?? 0
                        ])))
            .then((editedImageData) async {
          //await value.readAsBytes();
          printLog('[returned from imagePicker and Editing procedures]');
          printLog(
              'editedImageData length: ${editedImageData?.lengthInBytes} bytes');
          printLog('imagePickerXFile path is: ${value.path}');
          setState(() {
            imagePickerXFile = value;
            imageData = editedImageData;
          });
        });
      } else {
        doLock = false;
        printLog('[inactive lock canceled]');
      }
    });
    doLock = false;
    printLog('[inactive lock canceled]');
  }

  Future<void> doAskPermitions() async {
    printLog('[asking for permissions]');
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    //LocationData _locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      printLog('[service not enabled]');
      printLog('[start requesting service]');
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        printLog('[service not enabled after request]');
        return;
      }
    }
    printLog('[service enabled]');
    printLog('[checking permissions]');
    permissionGranted = await location.hasPermission();
    printLog('[permissions is]: $permissionGranted');
    if (permissionGranted == PermissionStatus.denied) {
      printLog('[permissions denied]');
      printLog('[start requesting permissions]');
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        printLog('[permissions denied after request]');
        return;
      }
      printLog('[permissions granted]');
      setState(() {
        locationPermission = true;
      });
    } else {
      setState(() {
        locationPermission = true;
      });
    }
  }
}
