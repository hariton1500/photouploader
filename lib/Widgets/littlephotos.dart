import 'package:flutter/material.dart';
import 'package:photouploader/Models/group.dart';
import 'package:photouploader/globals.dart';

Widget littleGroupPhotos(List<Photo> photos) {
  return Wrap(
    spacing: 5,
    children: photos
        .map((photo) => SizedBox(
              width: 40,
              child: Image.memory(photo.data!),
            ))
        .toList(),
  );
}

Widget littleGroupFiles(List<String> group) {
  return notUploadedFilesMap.isEmpty
      ? const Icon(Icons.abc)
      : Wrap(
          children: notUploadedFilesMap[(int.parse(group[0]))]!
              .map((e) => SizedBox(
                    width: 40,
                    child: Image.file(e),
                  ))
              .toList(),
        );
}
