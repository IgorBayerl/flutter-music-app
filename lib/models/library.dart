import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'playlist.dart';

class Library {
  /// Load all playlists from the shared preferences.
  /// Returns: a list of playlists.
  Future<List<Playlist>> loadPlaylists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistsStringList = prefs.getStringList('playlists') ?? [];
    print(playlistsStringList);
    List<Playlist> playlists = playlistsStringList
        .map((playlistString) => Playlist.fromJson(json.decode(playlistString)))
        .toList();

    return playlists;
  }

  /// Create a new playlist using the given title, save it to the shared preferences.
  /// Returns: the newly created playlist object.
  Future<Playlist> createPlaylist(String playlistTitle) async {
    // Create a new playlist object with an empty song list
    Playlist playlist = Playlist(
      id: UniqueKey().toString(),
      title: playlistTitle,
      songs: [],
    );

    // Save the playlist to the shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistsJson = prefs.getStringList('playlists') ?? [];
    playlistsJson.add(json.encode(playlist.toJson()));
    await prefs.setStringList('playlists', playlistsJson);

    return playlist;
  }

  /// Delete the playlist with the given id from the shared preferences.
  /// Returns: true if the playlist was successfully deleted, false otherwise.
  Future<bool> deletePlaylist(String playlistId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> playlistsJson = prefs.getStringList('playlists') ?? [];

    bool playlistDeleted = false;

    // Remove the playlist with the given id from the list of playlists
    List<String> updatedPlaylistsJson = playlistsJson.where((playlistJson) {
      Playlist playlist = Playlist.fromJson(json.decode(playlistJson));
      return playlist.id != playlistId;
    }).toList();

    // Update the shared preferences with the updated list of playlists
    if (updatedPlaylistsJson.length != playlistsJson.length) {
      await prefs.setStringList('playlists', updatedPlaylistsJson);
      playlistDeleted = true;
    }

    return playlistDeleted;
  }
}
