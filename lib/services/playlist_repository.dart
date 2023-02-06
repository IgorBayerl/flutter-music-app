import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'settings_service.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, String>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
}

class Playlist extends PlaylistRepository {
  // 'http://10.0.2.2:3000' localhost in android emulator
  String _musicServerUrl = '';

  final Dio _dio = Dio();

  Playlist() {
    _populateMusicServerUrl();
  }

  _populateMusicServerUrl() async {
    SettingsService _settingsService = GetIt.instance<SettingsService>();
    _musicServerUrl = await _settingsService.getMusicServerUrl();
  }

  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 3}) async {
    List<Map<String, String>> songs = [];
    for (int i = 0; i < length; i++) {
      Map<String, String> song = await _nextSong();
      songs.add(song);
    }
    return songs;
  }


  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  Future<Map<String, String>> _nextSong() async {
    if (_musicServerUrl == '') {
      await _populateMusicServerUrl();
    }

    Response response = await _dio.get(_musicServerUrl + '/music/random_song');
    final musicData = response.data;
    print('>>>> music URL = ${_musicServerUrl + musicData['url'].toString()}');
    return {
      'id': musicData['id'].toString(),
      'title': musicData['title'].toString(),
      'album': musicData['channel']['name'].toString(),
      'url': _musicServerUrl + musicData['url'].toString(),
    };
  }
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, String>>> fetchInitialPlaylist(
      {int length = 3}) async {
    return List.generate(length, (index) => _nextSong());
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  var _songIndex = 0;
  static const _maxSongNumber = 16;

  Map<String, String> _nextSong() {
    _songIndex = (_songIndex % _maxSongNumber) + 1;
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': 'Song $_songIndex',
      'album': 'SoundHelix',
      'url':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$_songIndex.mp3',
    };
  }
}
