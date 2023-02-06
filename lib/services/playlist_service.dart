import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PlaylistService {
  static const String _playlistArrayKey = 'playlist';

  Future<void> savePlaylist(List<Map<String, String>> playlist) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _playlistArrayKey, playlist.map((map) => map.toString()).toList());
  }

  Future<List<Map<String, String>>> loadPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final playlist = prefs.getStringList(_playlistArrayKey);

    if (playlist == null) return [];

    final maps = playlist.map((string) => jsonDecode(string));
    if (!maps.every((map) => map is Map<String, String>)) return [];

    return maps.cast<Map<String, String>>().toList();
  }

  Future<void> clearPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playlistArrayKey);
  }

  Future<void> addSong(Map<String, String> song) async {
    final playlist = await loadPlaylist();
    playlist.add(song);
    await savePlaylist(playlist);
  }

  Future<void> removeSong(Map<String, String> song) async {
    final playlist = await loadPlaylist();
    playlist.remove(song);
    await savePlaylist(playlist);
  }

  Future<void> printPlaylist() async {
    final playlist = await loadPlaylist();
    print(playlist);
  }
}
