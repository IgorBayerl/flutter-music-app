import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class PlaylistRepository {
  Future<List<Map<String, dynamic>>> fetchInitialPlaylist();
  Future<Map<String, String>> fetchAnotherSong();
  Future<void> testMehod();
}

class DemoPlaylist extends PlaylistRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchInitialPlaylist(
      {int length = 3}) async {

    String defaultUrl = 'http://10.0.2.2:3000/musics';
    final prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString('serverUrl') ?? defaultUrl;
    if (baseUrl == '') baseUrl = defaultUrl;

    /// Mover para um provider

    http.Response response = await http.get(Uri.parse(baseUrl));

    var musicsArr =
        new List<Map<String, dynamic>>.from(jsonDecode(response.body));

    print(musicsArr);
    return musicsArr;
  }

  @override
  Future<Map<String, String>> fetchAnotherSong() async {
    return _nextSong();
  }

  //test method
  Future<void> testMehod() async {
    print("BBBBB");
    http.Response response =
        await http.get(Uri.parse('http://10.0.2.2:3000/musics'));

    var musicsArr =
        new List<Map<String, dynamic>>.from(jsonDecode(response.body));

    print(musicsArr);
  }

  var _songIndex = 0;
  static const _maxSongNumber = 16;

  Map<String, String> _nextSong() {
    _songIndex = (_songIndex % _maxSongNumber) + 1;

    print('IGOR _songIndex: $_songIndex');
    return {
      'id': _songIndex.toString().padLeft(3, '0'),
      'title': 'Song $_songIndex',
      'album': 'SoundHelix',
      'url':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$_songIndex.mp3',
      // 'http://localhost:3000/public/1.mp3',
      // 'https://www.mboxdrive.com/Bleed%20It%20Out%20%20%20Linkin%20Park%20%20%20Bleed%20It%20Out.mp3',
    };
  }
}

// class Paylist extends PlaylistRepository {
//   //fetch from localhost:3000/musics a array of musics with id, title, album, url
//   @override
//   Future<List<dynamic>> fetchInitialPlaylist() async {
//     var response = await http.get(Uri.parse('http://localhost:3000/musics'));
//     // transform the array in the json in a List
//     print(jsonDecode(response.body));
//     return json.decode(response.body);
//   }

//   @override
//   Future<Map<String, String>> fetchAnotherSong() async {
//     return _nextSong();
//   }

//   Map<String, String> _nextSong() {
//     _songIndex = (_songIndex % _maxSongNumber) + 1;

//     print('IGOR _songIndex: $_songIndex');
//     return {
//       'id': _songIndex.toString().padLeft(3, '0'),
//       'title': 'Song $_songIndex',
//       'album': 'SoundHelix',
//       'url':
//           'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-$_songIndex.mp3',
//       // 'http://localhost:3000/public/1.mp3',
//       // 'https://www.mboxdrive.com/Bleed%20It%20Out%20%20%20Linkin%20Park%20%20%20Bleed%20It%20Out.mp3',
//     };
//   }
// }
