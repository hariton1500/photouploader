import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_painter/image_painter.dart';
import 'package:image_watermark/image_watermark.dart';

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

  @override
  void initState() {
    super.initState();
    memoryUint8List = File(widget.pathFromPicker).readAsBytesSync();
    //
    //makeEditProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editImageStageStrings[stage]!),
        actions: [
          if (stage == 'rotating') ...[
            IconButton(
                onPressed: () {
                  img.Image? image = img.decodeJpg(memoryUint8List);
                  image = img.copyRotate(img.decodeJpg(memoryUint8List)!, -90);
                  //File(widget.pathFromPicker).writeAsBytesSync(img.encodeJpg(image), flush: true);

                  setState(() {
                    memoryUint8List = Uint8List.fromList(img.encodeJpg(image!));
                  });
                },
                icon: const Icon(Icons.rotate_left)),
            IconButton(
                onPressed: () {
                  img.Image? image = img.decodeJpg(memoryUint8List);
                  image = img.copyRotate(image!, 90);
                  //File(widget.pathFromPicker).writeAsBytesSync(img.encodeJpg(image), flush: true);
                  setState(() {
                    memoryUint8List = Uint8List.fromList(img.encodeJpg(image!));
                  });
                },
                icon: const Icon(Icons.rotate_right)),
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
                  });
                  returnEditedImage(watermarkedUint8List);
                },
                icon: const Icon(Icons.save_alt)),
          ]
        ],
        centerTitle: true,
      ),
      body: SafeArea(
          child: stage == 'rotating'
              ? Image.memory(memoryUint8List)
              : ImagePainter.memory(memoryUint8List, key: _imageKey)),
    );
  }

  void returnEditedImage(Uint8List watermarkedUint8List) {
    Navigator.pop(context, watermarkedUint8List);
  }
}
