import 'dart:convert';

import 'package:flutter_audio_service_demo/interfaces/Song.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistService {
  static const String _playlistArrayKey = 'playlist';

  Future<void> savePlaylist(List<Song> playlist) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistJson = jsonEncode(playlist);

    await prefs.setString(_playlistArrayKey, playlistJson);
  }

  Future<List<Song>> loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistJson = prefs.getString(_playlistArrayKey);
    if (playlistJson == null) return [];

    final playlist = jsonDecode(playlistJson) as List;

    return playlist.map((song) => Song.fromJson(song)).toList();
  }

  Future<void> clearPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playlistArrayKey);
  }

  Future<void> addSong(Song song) async {
    final playlist = await loadPlaylist();
    playlist.add(song);
    await savePlaylist(playlist);
  }

  Future<void> removeSong(Song song) async {
    final playlist = await loadPlaylist();
    playlist.remove(song);
    await savePlaylist(playlist);
  }

  Future<void> printPlaylist() async {
    final playlist = await loadPlaylist();
    print(playlist);
  }
}
