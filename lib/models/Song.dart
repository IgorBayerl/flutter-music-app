import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Song {
  final String id;
  final String title;
  final String album;
  final String artist;
  final String remotePath;
  final String localPath;
  final String songServerUrl;
  final bool isDownloaded;
  final Duration duration;
  final int sizeInBytes;
  final String artworkUrl;

  Song({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.remotePath,
    this.localPath = "",
    this.songServerUrl = "",
    this.isDownloaded = false,
    required this.duration,
    required this.sizeInBytes,
    this.artworkUrl = "",
  });

  // A method to download the song from the remotePath to the localPath
  Future<bool> download() async {
    try {
      //TODO: Add your download logic here

      // Once the download is complete, save the Song object to flutter_secure_storage
      final storage = new FlutterSecureStorage();
      await storage.write(key: id, value: json.encode(toJson()));

      return true; // return true if download was successful
    } catch (e) {
      print('Error downloading song: $e');
      return false; // return false if download failed
    }
  }

  // TODO: A method to delete the song from the localPath
  Future<bool> delete() async {
    // Add your delete logic here
    return true; // return true if delete was successful
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      album: json['album'] as String,
      artist: json['artist'] as String,
      remotePath: json['remotePath'] as String,
      localPath: json['localPath'] as String,
      songServerUrl: json['songServerUrl'] as String,
      isDownloaded: json['isDownloaded'] as bool,
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
      'localPath': localPath,
      'songServerUrl': songServerUrl,
      'isDownloaded': isDownloaded,
      'duration': duration.inMilliseconds,
      'sizeInBytes': sizeInBytes,
      'artworkUrl': artworkUrl,
    };
  }
}
