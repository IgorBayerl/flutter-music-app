import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'song.dart';

class Playlist {
  final String id;
  final String title;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.title,
    required this.songs,
  });

  /// Add a song to the playlist
  void addSong(Song song) {
    songs.add(song);
  }

  /// Remove a song from the playlist by ID
  void removeSong(String songId) {
    songs.removeWhere((song) => song.id == songId);
  }

  /// Load a playlist from shared preferences
  /// The musics are not loaded by default because it would be too slow when loading all the playlists
  Future<Playlist> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final playlistJson = prefs.getString(this.id);
    if (playlistJson != null) {
      return Playlist.fromJson(jsonDecode(playlistJson));
    } else {
      // If the playlist doesn't exist, create an empty one
      return Playlist(
        id: this.id,
        title: this.title,
        songs: [],
      );
    }
  }

  Future<void> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(this.id, jsonEncode(this.toJson()));
  }

  /// Get the total duration of the playlist
  Duration get totalDuration {
    return songs.fold(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );
  }

  // Get the total size of the playlist in bytes
  int get totalSizeInBytes {
    return songs.fold(
      0,
      (acc, song) => acc + song.sizeInBytes,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final List<dynamic> songsJson = json['songs'];
    final List<Song> songs =
        songsJson.map((songJson) => Song.fromJson(songJson)).toList();
    return Playlist(
      id: json['id'] as String,
      title: json['title'] as String,
      songs: songs,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> songsJson =
        songs.map((song) => song.toJson()).toList();
    return {
      'id': id,
      'title': title,
      'songs': songsJson,
    };
  }
}
