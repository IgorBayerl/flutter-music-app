import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class Song {
  final String id;
  final String title;
  final String album;
  final String artist;
  final String remotePath;
  final String songServerUrl;
  final Duration duration;
  final int sizeInBytes;
  final String artworkUrl;
  String localPath = "";
  bool isLoading = false;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.remotePath,
    this.songServerUrl = "",
    required this.duration,
    required this.sizeInBytes,
    this.artworkUrl = "",
  }) {
    initializeLocalPath();
  }

  // A method to download the song from the remotePath to the localPath
  Future<void> download() async {
    try {
      Dio dio = Dio();

      print(remotePath);

      //Make sure localPath is not already set and remotePath is valid
      if (isDownloaded || remotePath.isEmpty) {
        throw Exception('Song is already downloaded or remotePath is invalid');
      }

      // define the name in which the song will be saved
      String _fileName = '$id.mp3';

      // get the directory where the song will be saved
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('External storage not found');

      // define the localPath
      String _filePath = '${dir.path}/$_fileName';

      // verify if the file already exists
      File file = File(_filePath);
      if (await file.exists()) {
        await delete();
      }

      // download the song
      await dio.download(remotePath, _filePath,
          onReceiveProgress: (received, total) {
        if (total != -1) {
          print((received / total * 100).toStringAsFixed(0) + "%");
        }
      });

      // save the localPath in the secure storage
      await _saveLocalPath(id, _filePath);

      print('Download completed: $localPath');
    } catch (e) {
      print('Error downloading song: $e');
    }
  }

  // TODO: A method to delete the song from the localPath
  Future<void> delete() async {
    try {
      // Make sure localPath is set and the file exists
      if (!isDownloaded) {
        throw Exception('Song is not downloaded');
      }
      File file = File(localPath);
      if (!await file.exists()) {
        throw Exception('Song file not found');
      }
      // Delete the file
      await file.delete();
      // Remove the localPath from secure storage
      final storage = FlutterSecureStorage();
      await storage.delete(key: id);
      localPath = "";
      print('Song deleted: $title');
    } catch (e) {
      print('Error deleting song: $e');
    }
  }

  factory Song.fromMediaItem(MediaItem mediaItem) {
    return Song(
      id: mediaItem.id,
      title: mediaItem.title,
      album: mediaItem.album ?? '',
      remotePath: mediaItem.extras!['remotePath'],
      songServerUrl: mediaItem.extras!['songServerUrl'] ?? '',
      artist: '',
      duration: mediaItem.duration ?? Duration.zero,
      sizeInBytes: mediaItem.extras!['sizeInBytes'] ?? 0,
      artworkUrl: '',
    );
  }

  MediaItem toMediaItem() {
    return MediaItem(
      id: id,
      album: album,
      title: title,
      duration: duration,
      artUri: artworkUrl.isNotEmpty ? Uri.parse(artworkUrl) : null,
      extras: {
        'remotePath': remotePath,
        'localPath': localPath,
        'songServerUrl': songServerUrl,
      },
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      album: json['album'] as String,
      artist: json['artist'] as String,
      remotePath: json['remotePath'] as String,
      songServerUrl: json['songServerUrl'] as String,
      duration: Duration(milliseconds: json['duration'] as int),
      sizeInBytes: json['sizeInBytes'] as int,
      artworkUrl: json['artworkUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'album': album,
      'artist': artist,
      'remotePath': remotePath,
      'songServerUrl': songServerUrl,
      'duration': duration.inMilliseconds,
      'sizeInBytes': sizeInBytes,
      'artworkUrl': artworkUrl,
    };
  }

  Future<void> initializeLocalPath() async {
    isLoading = true;
    final storage = FlutterSecureStorage();
    localPath = await storage.read(key: id) ?? '';
    isLoading = false;
  }

  Future<void> _saveLocalPath(String _id, String _localPath) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: _id, value: _localPath);
  }

  bool get isDownloaded => localPath.isNotEmpty;
}
