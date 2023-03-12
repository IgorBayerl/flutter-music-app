import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Song {
  final String id;
  final String title;
  final String album;
  final String remotePath;
  late String localPath;
  final String songServerUrl;
  final bool isLocalPath;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.remotePath,
    required this.songServerUrl,
    this.localPath = '',
  }) : isLocalPath = localPath.isNotEmpty {
    initLocalPath();
  }

  Future<void> initLocalPath() async {
    localPath = await _getLocalPath(id, songServerUrl);
  }

  static Future<String> _getLocalPath(String id, String serverUrl) async {
    Directory? dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception("External storage not found");

    String localPath = "${dir.path}/$id.mp3";
    if (await File(localPath).exists()) {
      return localPath;
    }
    return "";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album': album,
      'remotePath': remotePath,
      'localPath': localPath,
      'isLocalPath': isLocalPath,
      'songServerUrl': songServerUrl,
    };
  }

  static Song fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      album: json['album'] as String,
      remotePath: json['remotePath'] as String,
      localPath: json['localPath'] as String,
      songServerUrl: json['songServerUrl'] as String,
    );
  }
}
