import 'dart:io';
import 'package:flutter/material.dart';

class PictureShowPage extends StatefulWidget {
  const PictureShowPage(
      {super.key, required this.file, required this.description});
  final String file;
  final String description;

  @override
  State<PictureShowPage> createState() => _PictureShowPageState();
}

class _PictureShowPageState extends State<PictureShowPage> {
  @override
  Widget build(BuildContext context) {
    print(widget.file);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.file(File(widget.file)),
      ),
    );
  }
}
