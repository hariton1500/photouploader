import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
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

  @override
  void initState() {
    super.initState();
    uploader.cancelAll();
    uploader.clearUploads();
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
      printLog('result.response: ${result.response}');
      printLog('result.status: ${result.status?.description}');
      if (groupsTasksIds.containsKey(result.taskId)) {
        var groupId = groupsTasksIds[result.taskId];
        if (result.response != null &&
            jsonDecode(result.response!)['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Группа ${groupId.hashCode} загружена')));
          var targetGroup =
              notUploaded.firstWhere((element) => element.contains(groupId));
          try {
            int numberOfPhotos = (jsonDecode(targetGroup[2]) as List).length;
            for (var i = 0; i < numberOfPhotos; i++) {
              File('${(await getApplicationSupportDirectory()).path}/${targetGroup[0]}-$i.jpg')
                  .delete();
            }
          } catch (e) {
            print(e);
          }
          notUploaded.removeWhere((element) => element.contains(groupId));
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString('notUploaded', jsonEncode(notUploaded));
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
    print(notUploaded);
    return Scaffold(
      appBar: AppBar(
        /*
        actions: [
          IconButton(
              onPressed: () {
                showAdaptiveDialog(
                    context: context,
                    builder: (context) => Scaffold(
                          body: Text(appLog),
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
                print(group);
                return ListTile(
                  leading: Text(group[0].hashCode.toString()),
                  title: Wrap(
                    children: [
                      const Text('Описание группы: '),
                      Text(group[1].toString()),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      const Text('количество фото: '),
                      Text((jsonDecode(group[2]) as List).length.toString()),
                    ],
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
                              print(geoFiles);

                              Api api = Api();
                              api
                                  .uploadGroupByUploader(secretKey, group[1],
                                      geoFiles, files, group[0])
                                  .then((taskId) {
                                groupsTasksIds[taskId] = group[0];
                              });
                            } catch (e) {
                              print(e);
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
}
