import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photouploader/Pages/menu.dart';
import 'package:photouploader/Services/api.dart';
import 'package:photouploader/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  Map<String, int> groupsProgress = {};
  Map<String, String> groupsTasksIds = {};
  StreamSubscription<UploadTaskProgress>? _progressSubscription;
  StreamSubscription<UploadTaskResponse>? _resultSubscription;
  Map<String, List<Widget>> littlesByGroup = {};

  @override
  void initState() {
    super.initState();
    uploader.cancelAll();
    uploader.clearUploads();
    getLittles();

    for (var group in notUploaded) {
      groupsProgress[group[0]] = 0;
    }
    _progressSubscription = uploader.progress.listen((progress) {
      setState(() {
        print('progress.status: ${progress.status.description}');
        var groupId = groupsTasksIds[progress.taskId];
        if (groupId != null) {
          groupsProgress[groupId] = progress.progress ?? 0;
        }
      });
    });
    _resultSubscription = uploader.result.listen((result) async {
      if (groupsTasksIds.containsKey(result.taskId)) {
        var groupId = groupsTasksIds[result.taskId];
        try {
          printLog('=================-result.response:-==================');
          printLog(jsonDecode(result.response!));
          printLog('=====================================================');
        } catch (e) {
          printLog('result.response: ${result.response}');
          printLog('result.status: ${result.status?.description}');
        }
        if (result.response != null &&
            !result.response!.startsWith('<html>') &&
            jsonDecode(result.response!)['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Группа ${groupId.hashCode} загружена')));
          var targetGroup =
              notUploaded.firstWhere((element) => element.contains(groupId));
          try {
            int numberOfPhotos = (jsonDecode(targetGroup[2]) as List).length;
            for (var i = 0; i < numberOfPhotos; i++) {
              File('${(await getApplicationSupportDirectory()).path}/${targetGroup[0]}-$i.jpg')
                  .delete()
                  .then((value) => printLog('${value.path} is deleted'));
            }
          } catch (e) {
            printLog(e);
          }
          notUploaded.removeWhere((element) => element.contains(groupId));
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('notUploaded', jsonEncode(notUploaded));
          //setState(() {});
        } else if (result.status == UploadTaskStatus.complete &&
            jsonDecode(result.response!)['status'] != 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  'Произошла ошибка при загрузке группы ${groupId.hashCode}')));
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _progressSubscription?.cancel();
    _resultSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //print(notUploaded);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const NormalModePage()));
            },
            icon: const Icon(Icons.arrow_back)),
        /*
        actions: [
          IconButton(
              onPressed: () {
                showAdaptiveDialog(
                    context: context,
                    builder: (context) => Scaffold(
                          body: SingleChildScrollView(
                              child:
                                  Text(appLog.substring(appLog.length - 3000))),
                        ));
              },
              icon: const Icon(Icons.screenshot_monitor))
        ],*/
        title: const Text('Загрузка фото на сервер'),
      ),
      body: SingleChildScrollView(
        child: notUploaded.isEmpty
            ? const Center(child: Text('Незагруженных фотографий нет'))
            : Column(
                children: notUploaded.map((group) {
                printLog(group);
                return ListTile(
                  //leading: littleGroupFiles(group),
                  title: Wrap(
                    children: [
                      //const Text('Описание группы: '),
                      Text(group[1].toString()),
                    ],
                  ),
                  subtitle: Wrap(
                    spacing: 5,
                    children:
                        //const Text('количество фото: '),
                        //Text((jsonDecode(group[2]) as List).length.toString()),
                        !(littlesByGroup.containsKey(group[1]) &&
                                littlesByGroup[group[1]]!.isNotEmpty)
                            ? [
                                const CircularProgressIndicator(
                                  strokeWidth: 1,
                                )
                              ]
                            : littlesByGroup[group[1]]!,
                  ),
                  trailing: groupsProgress[group[0]] == 0
                      ? IconButton(
                          onPressed: () async {
                            List<String> files = [];
                            Map<String, String> geoFiles = {};
                            //read files
                            try {
                              String basePath =
                                  (await getApplicationSupportDirectory()).path;
                              List f = jsonDecode(group[2]) as List;
                              for (var i = 0; i < f.length; i++) {
                                String path = '$basePath/${group[0]}-$i.jpg';
                                debugPrint(path);
                                geoFiles['${group[0]}-$i.jpg'] =
                                    '${f[i][1]}, ${f[i][2]}';
                                files.add(path);
                                //XFile(path).readAsBytes();
                                //XFile(path);
                              }
                              printLog(geoFiles);

                              Api api = Api();
                              api
                                  .uploadGroupByUploader(secretKey, group[1],
                                      geoFiles, files, group[0])
                                  .then((taskId) {
                                groupsTasksIds[taskId] = group[0];
                              });
                            } catch (e) {
                              printLog(e);
                            }
                            //upload files
                            //on success delete files and remove from notUploaded
                          },
                          icon: const Icon(Icons.upload))
                      : Text('${groupsProgress[group[0]]} %'),
                );
              }).toList()),
      ),
    );
  }

  Future<void> getLittles() async {
    String baseDir = (await getApplicationSupportDirectory()).path;
    for (var group in notUploaded) {
      littlesByGroup[group[1]] = [];
      var data = (jsonDecode(group[2]));
      for (var i = 0; i < data.length; i++) {
        String path = '$baseDir/${group[0]}-$i.jpg';
        printLog(path);
        littlesByGroup[group[1]]
            ?.add(SizedBox(width: 60, child: Image.file(File(path))));
        setState(() {});
      }
    }
  }
}
