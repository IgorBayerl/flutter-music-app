import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  //TODO: uldate the playlist isLocalPath and url to true when download is completed
  Future<void> downloadMusic(String musicUrl) async {
    Dio dio = Dio();

    try {
      Uri musicUri = Uri.parse(musicUrl);

      String? fileName = musicUri.queryParameters['v'];
      if (fileName == null) throw Exception("Invalid URL");

      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception("External storage not found");

      String filePath = "${dir.path}/$fileName.mp3";

      await dio.download(musicUrl, filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print((received / total * 100).toStringAsFixed(0) + "%");
        }
      });
      print("Download completed: $filePath");
    } catch (e) {
      print(e);
    }
  }

  Future<List<String>> getDownloadedMusics() async {
    Directory? dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception("External storage not found");

    List<String> downloadedMusic = [];
    List<FileSystemEntity> files = dir.listSync();
    files.forEach((file) {
      if (file.path.endsWith(".mp3")) {
        downloadedMusic.add(file.path);
      }
    });
    return downloadedMusic;
  }

  Future<String> getMusicPathById(String musicId) async {
    Directory? dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception("External storage not found");

    List<FileSystemEntity> files = dir.listSync();
    for (FileSystemEntity file in files) {
      if (file.path.endsWith(".mp3")) {
        String fileName = file.path.split("/").last;
        String id = fileName.split(".").first;
        if (id == musicId) {
          return file.path;
        }
      }
    }
    throw Exception("Music not found");
  }

  Future<void> deleteMusic(String musicPath) async {
    File file = File(musicPath);
    await file.delete();
  }
}
