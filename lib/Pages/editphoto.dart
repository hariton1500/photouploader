import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';

//import 'package:location_platform_interface/location_platform_interface.dart';

class EditPhotoPage extends StatefulWidget {
  final XFile photo;
  final String description;

  final List<double> coords;

  const EditPhotoPage(
      {super.key,
      required this.photo,
      required this.description,
      required this.coords});

  @override
  State<EditPhotoPage> createState() => _EditPhotoPageState();
}

class _EditPhotoPageState extends State<EditPhotoPage> {
  late img.Image image;
  Image? imageToShow;
  Uint8List memoryUint8List = Uint8List.fromList([]);

  @override
  void initState() {
    super.initState();
    setState(() {
      imageToShow = Image.file(File(widget.photo.path));
    });
    memoryUint8List = File(widget.photo.path).readAsBytesSync();
    //
    //makeEditProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                image = img.decodeJpg(memoryUint8List)!;
                image = img.copyRotate(image, -90);
                //File(widget.photo.path).writeAsBytesSync(img.encodeJpg(image), flush: true);
                memoryUint8List = Uint8List.fromList(img.encodeJpg(image));
                setState(() {
                  imageToShow = Image.memory(memoryUint8List);
                });
              },
              icon: const Icon(Icons.rotate_left)),
          IconButton(
              onPressed: () {
                image = img.decodeJpg(memoryUint8List)!;
                image = img.copyRotate(image, 90);
                memoryUint8List = Uint8List.fromList(img.encodeJpg(image));
                setState(() {
                  imageToShow = Image.memory(memoryUint8List);
                });
              },
              icon: const Icon(Icons.rotate_right)),
          IconButton(
              onPressed: () async {
                var watermarkedUint8List =
                    await ImageWatermark.addTextWatermark(
                  imgBytes: memoryUint8List,
                  watermarkText: '${widget.description}\n${widget.coords}',
                  dstX: 0,
                  dstY: 0,
                  color: Colors.red,
                );
                memoryUint8List = watermarkedUint8List;
                setState(() {
                  imageToShow = Image.memory(memoryUint8List);
                });
              },
              icon: const Icon(Icons.place)),
          IconButton(
              onPressed: () {
                //File(widget.photo.path).writeAsBytesSync(memoryUint8List.toList(), flush: true);
                //widget.photo.saveTo(widget.photo.path);
                //XFile newPhoto = XFile.fromData(memoryUint8List, path: widget.photo.path);
                //newPhoto.saveTo(widget.photo.path);
                File(widget.photo.path).writeAsBytesSync(img.encodeJpg(image));
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.save)),
        ],
      ),
      body: SafeArea(
          child: imageToShow != null
              ? AspectRatio(
                  aspectRatio: 1,
                  child: imageToShow,
                )
              : const Center(child: CircularProgressIndicator())),
    );
  }

  void makeEditProcedures() async {
    //File photoFile = File(widget.photo.path);
    image = img.decodeJpg(File(widget.photo.path).readAsBytesSync())!;
    image = img.bakeOrientation(image);
    print('image width: ${image.width}');
    print('image height: ${image.height}');
    //image = img.copyRotate(image, 90);
    print(image.exif.exifIfd.data);

    File(widget.photo.path).writeAsBytesSync(img.encodeJpg(image), flush: true);
    var t = await widget.photo.readAsBytes();

    final watermarkedImg = await ImageWatermark.addTextWatermark(
      imgBytes: t,
      watermarkText: '${widget.description}\n${widget.coords}',
      dstX: 0,
      dstY: 0,
      color: Colors.red,
    );
    File(widget.photo.path).writeAsBytesSync(watermarkedImg, flush: true);
    imageToShow = Image.file(File(widget.photo.path));
    /*
    final textOption = AddTextOption();
    textOption.addText(
      const EditorText(
        offset: Offset(0, 0),
        text: 'test',
        fontSizePx: 10,
        textColor: Colors.red,
        fontName:
            '', // You must register font before use. If the fontName is empty string, the text will use default system font.
      ),
    );
    var f = await ImageEditor.editFileImage(
        file: photoFile,
        imageEditorOption: ImageEditorOption()..addOption(textOption));
    await File(widget.photo.path).writeAsBytes(f!.buffer
        .asUint8List()); //write edited file to disk using readAsBytes() instead of readAsBytesSync()*/
    setState(() {});
  }
}
