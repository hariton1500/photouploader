import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photouploader/Models/group.dart';

Widget littleGroupPhotos(List<Photo> photos, int rotation) {
  return Wrap(
    spacing: 5,
    children: photos
        .map((photo) => SizedBox(
              width: 40,
              child: RotatedBox(
                  quarterTurns: rotation, child: Image.file(File(photo.path!))),
            ))
        .toList(),
  );
}
