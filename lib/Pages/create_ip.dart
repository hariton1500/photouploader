import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photouploader/Models/group.dart';
import 'package:photouploader/Pages/editphoto.dart';
import 'package:photouploader/Widgets/littlephotos.dart';
import 'package:photouploader/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePage2 extends StatefulWidget {
  const CreatePage2({super.key});

  @override
  State<CreatePage2> createState() => _CreatePage2State();
}

class _CreatePage2State extends State<CreatePage2> {
  final Location location = Location();
  LocationData? _location;
  bool isEditDescrition = false;
  String description = '';
  int rotation = 0;
  XFile? imagePickerXFile;
  Uint8List? imageData;
  List<Photo> photosGroup = [];

  @override
  void initState() {
    super.initState();
    doAskPermitions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('Создание фотографии'),
        centerTitle: true,
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
            ] else ...[
              TextButton.icon(
                  onPressed: () {
                    setState(() {
                      isEditDescrition = !isEditDescrition;
                    });
                  },
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
                child: littleGroupPhotos(photosGroup, rotation),
              ),
              TextButton.icon(
                  onPressed: () async {
                    int index = DateTime.now().microsecondsSinceEpoch;
                    List<dynamic> group = [];
                    for (var i = 0; i < photosGroup.length; i++) {
                      print('original path in memory: ${photosGroup[i].path}');
                      //photosGroup[i].photo?.writeAsBytesSync(bytes);
                      group.add([
                        i.toString(),
                        photosGroup[i].lat.toString(),
                        photosGroup[i].long.toString()
                      ]);
                    }
                    notUploaded.add(
                        [index.toString(), description, jsonEncode(group)]);
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
                      String path =
                          (await getApplicationSupportDirectory()).path;
                      path +=
                          '/${DateTime.now().microsecondsSinceEpoch}-${photosGroup.length}.jpg';
                      File(path).writeAsBytesSync(imageData!);
                      setState(() {
                        photosGroup.add(Photo(
                            long: _location!.longitude,
                            lat: _location!.latitude,
                            path: path,
                            data: imageData));
                        imageData = null;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Добавить в группу'))
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                builder: (context) => EditPhotoPage(
                        photo: value,
                        description: description,
                        coords: [
                          _location!.longitude ?? 0,
                          _location!.latitude ?? 0
                        ])))
            .then((editedImageData) async {
          //await value.readAsBytes();
          setState(() {
            imagePickerXFile = value;
            imageData = editedImageData;
          });
        });
      }
    });
  }

  Future<void> doAskPermitions() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    //LocationData _locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }
}
