import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:photouploader/globals.dart';
//import 'package:photouploader/Fonts/roboto.dart';

Map<String, String> editImageStageStrings = {
  "rotating": "Вращаем фото",
  "painting": "Рисуем на фото",
};

class EditImagePage extends StatefulWidget {
  const EditImagePage(
      {super.key,
      required this.pathFromPicker,
      required this.description,
      required this.coords});
  final String pathFromPicker;
  final String description;
  final List<double> coords;

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  String stage = 'rotating';
  //img.Image? image;
  Uint8List memoryUint8List = Uint8List.fromList([]);
  final _imageKey = GlobalKey<ImagePainterState>();

  bool isProcessing = false;

  @override
  void initState() {
    doLock = false;
    printLog('[inactive lock canceled]');
    super.initState();
    memoryUint8List = File(widget.pathFromPicker).readAsBytesSync();
  }

  @override
  Widget build(BuildContext context) {
    printLog('[editimagepage build with stage: $stage]');
    return Scaffold(
      appBar: AppBar(
        title: Text(editImageStageStrings[stage]!),
        actions: [
          if (stage == 'rotating') ...[
            IconButton(
                onPressed: () {
                  setState(() {
                    isProcessing = true;
                  });
                  img.Image? image = img.decodeJpg(memoryUint8List);
                  image = img.copyRotate(img.decodeJpg(memoryUint8List)!,
                      angle: -90);
                  //File(widget.pathFromPicker).writeAsBytesSync(img.encodeJpg(image), flush: true);

                  setState(() {
                    memoryUint8List = Uint8List.fromList(img.encodeJpg(image!));
                    isProcessing = false;
                  });
                },
                icon: const Icon(Icons.rotate_left)),
            IconButton(
                onPressed: () {
                  setState(() {
                    isProcessing = true;
                  });
                  img.Image? image = img.decodeJpg(memoryUint8List);
                  image = img.copyRotate(image!, angle: 90);
                  //File(widget.pathFromPicker).writeAsBytesSync(img.encodeJpg(image), flush: true);
                  setState(() {
                    memoryUint8List = Uint8List.fromList(img.encodeJpg(image!));
                    isProcessing = false;
                  });
                },
                icon: const Icon(Icons.rotate_right)),
            /*
            IconButton(
                onPressed: () {
                  img.Image? image = img.decodeJpg(memoryUint8List);
                  image = img.drawString(
                      image!, '${widget.description}\n${widget.coords}',
                      font: roboto64, x: 10, y: 10);
                  setState(() {
                    memoryUint8List = Uint8List.fromList(img.encodeJpg(image!));
                  });
                },
                icon: const Icon(Icons.location_pin)),*/
            IconButton(
                onPressed: () {
                  setState(() {
                    stage = 'painting';
                  });
                },
                icon: const Icon(Icons.navigate_next)),
          ],
          if (stage == 'painting') ...[
            IconButton(
                onPressed: () async {
                  setState(() {
                    isProcessing = true;
                  });
                  /*
                  memoryUint8List =
                      (await _imageKey.currentState!.exportImage())!;
                  var watermarkedUint8List =
                      await ImageWatermark.addTextWatermark(
                    imgBytes: memoryUint8List,
                    watermarkText: '${widget.description}\n${widget.coords}',
                    dstX: 0,
                    dstY: 0,
                    color: Colors.red,
                  );
                  setState(() {
                    memoryUint8List = watermarkedUint8List;
                    isProcessing = false;
                  });*/
                  returnEditedImage(
                      (await _imageKey.currentState!.exportImage())!);
                },
                icon: const Icon(Icons.save_alt)),
          ]
        ],
        centerTitle: true,
      ),
      body: SafeArea(
          child: stage == 'rotating'
              ? isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : Image.memory(memoryUint8List)
              : isProcessing
                  ? const Center(child: CircularProgressIndicator())
                  : ImagePainter.memory(
                      memoryUint8List,
                      key: _imageKey,
                      //watermarkText: '${widget.description}\n${widget.coords}',
                    )),
    );
  }

  void returnEditedImage(Uint8List newUint8List) {
    doLock = false;
    printLog('[inactive lock canceled]');
    Navigator.pop(context, newUint8List);
  }
}
