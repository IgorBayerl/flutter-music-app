import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_audio_service_demo/services/page_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

import '../interfaces/Song.dart';
import 'playlist_service.dart';
import 'settings_service.dart';

abstract class PlaylistRepository {
  Future<List<Song>> fetchInitialPlaylist();
  Future<Song> fetchAnotherSong();
}

class Playlist extends PlaylistRepository {
  // 'http://10.0.2.2:3000' localhost in android emulator
  String _musicServerUrl = '';

  final Dio _dio = Dio();

  Playlist() {
    _populateMusicServerUrl();
  }

  Future<void> _populateMusicServerUrl() async {
    SettingsService _settingsService = GetIt.instance<SettingsService>();
    _musicServerUrl = await _settingsService.getMusicServerUrl();
  }

  @override
  Future<List<Song>> fetchInitialPlaylist({int length = 3}) async {
    List<Song> songs = [];

    try {
      PlaylistService _playlistService = GetIt.instance<PlaylistService>();
      final savedPlaylist = await _playlistService.loadPlaylist();
      if (savedPlaylist.isNotEmpty) {
        songs = savedPlaylist;
        return songs;
      }
    } catch (e) {
      print(e);
    }

    for (int i = 0; i < length; i++) {
      Song song = await _nextSong();
      songs.add(song);
    }
    return songs;
  }

  @override
  Future<Song> fetchAnotherSong() async {
    return _nextSong();
  }

  Future<String> getMusicPath(String id) async {
    Directory? dir = await getExternalStorageDirectory();
    if (dir == null) throw Exception("External storage not found");

    String localPath = "${dir.path}/$id.mp3";
    if (await File(localPath).exists()) {
      return localPath;
    }
    return "$_musicServerUrl/music/play?v=$id";
  }

  Future<Song> _nextSong() async {
    if (_musicServerUrl == '') {
      await _populateMusicServerUrl();
    }

    Response response = await _dio.get(_musicServerUrl + '/music/random_song');
    final musicData = response.data;

    // String _musicPath = await getMusicPath(musicData['id'].toString());
    // bool isLocalPath = _musicPath.startsWith('/');

    final _remotePath = _musicServerUrl + musicData['url'].toString();

    return Song(
      id: musicData['id'].toString(),
      title: musicData['title'].toString(),
      album: musicData['album'].toString(),
      remotePath: _remotePath,
      songServerUrl: _musicServerUrl,
    );
  }
}
