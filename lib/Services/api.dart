import 'dart:convert';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:photouploader/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  final String baseUrl = 'https://cloudphoto-stuff.ru';

  Api();

  Future<Map<String, dynamic>> authenticate(
      String login, String password) async {
    http.Response response = http.Response('', 511);
    try {
      response = await http.post(
        Uri.parse('$baseUrl/api/auth'),
        body: {
          'login': login,
          'passwd': password,
        },
      );
    } catch (e) {
      print(e);
    }
    if (response.statusCode == 511) {
      return {'status': 'error', 'message': 'Ошибка соединения'};
    } else {
      return _handleResponse(response);
    }
  }

  Future<Map<String, dynamic>> checkSession(String apiKey) async {
    http.Response response = http.Response('', 511);
    try {
      response = await http.get(
        Uri.parse('$baseUrl/api/check'),
        headers: {
          'X-Api-Key': apiKey,
        },
      );
    } catch (e) {
      print(e);
    }
    if (response.statusCode == 511) {
      return {'status': 'error', 'message': 'Ошибка соединения'};
    } else {
      return _handleResponse(response);
    }
  }

  Future<String> uploadGroupByUploader(String apiKey, String description,
      Map<String, String> filesGeo, List<String> files, String groupId) async {
    final taskId = await uploader.enqueue(MultipartFormDataUpload(
        tag: groupId,
        url: '$baseUrl/api/put_files',
        headers: {'X-Api-Key': apiKey},
        files: files.map((file) => FileItem(path: file)).toList(),
        data: {
          'description': description,
          'geo_files': jsonEncode(filesGeo),
          'file': jsonEncode(files.map((file) => file.split('/').last).toList())
        }));
    return taskId;
  }

  Future<bool> uploadGroup(String apiKey, String description,
      Map<String, String> filesGeo, List<String> files) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/api/put_files'));
    print('files: $files');
    if (files.isNotEmpty) {
      for (var file in files) {
        request.files
            .add(await http.MultipartFile.fromPath(file.split('/').last, file));
        print(request.files.last.filename);
      }
    }
    /*
    final response = await http.post(Uri.parse('$baseUrl/api/put_files'), headers: {
      'X-Api-Key': apiKey,
    }, body: {
      'description': description,
      'geo_files': jsonEncode(filesGeo),
      'file': files
    });*/
    request.fields['description'] = description;
    request.fields['geo_files'] = jsonEncode(filesGeo);
    request.fields['file'] = jsonEncode(files);
    request.headers['X-Api-Key'] = secretKey;
    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });

    return response.statusCode == 200;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print(response.statusCode);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      //print(responseData);
      if (responseData.containsKey('status') &&
          responseData['status'] == 'success') {
        return responseData;
      } else {
        return {'status': 'error', 'message': 'Bad API key'};
      }
    } else if (response.statusCode == 400) {
      //print(response.body);
      return {'status': 'error', 'message': 'Not all parameters were passed.'};
    } else if (response.statusCode == 401) {
      //print(response.body);
      return {'status': 'error', 'message': 'Invalid authorization.'};
    } else {
      //print(response.body);
      return {'status': 'error', 'message': 'Unknown error'};
    }
  }

  Future<void> saveSecretKey(String secretKey) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('secretKey', secretKey);
  }
}
