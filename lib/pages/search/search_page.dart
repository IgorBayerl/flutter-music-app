import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_service_demo/models/song.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/library.dart';
import '../../models/playlist.dart';
import '../../services/settings_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _searching = false;
  String _musicServerUrl = '';

  final Dio _dio = Dio();

  _SearchPageState() {
    _populateMusicServerUrl();
  }

  Future<void> _populateMusicServerUrl() async {
    SettingsService _settingsService = GetIt.instance<SettingsService>();
    _musicServerUrl = await _settingsService.getMusicServerUrl();
  }

  void _addToPlaylist(Song songInfo, Playlist playlist) async {
    try {
      final Playlist _newPlaylist = await playlist.load();
      _newPlaylist.addSong(songInfo);
      await _newPlaylist.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to ${playlist.title}'),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add song to playlist.'),
        ),
      );
    }
  }

  void _showPlaylistsModal(Song songInfo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        Library _library = Library();
        Future<List<Playlist>> _playlistsFuture = _library.loadPlaylists();

        return Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: _playlistsFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Playlist>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show spinner while loading
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Show error message
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Show list of playlists
                  List<Playlist> _playlists = snapshot.data!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _playlists.length,
                          itemBuilder: (BuildContext context, int index) {
                            final playlist = _playlists[index];
                            return ListTile(
                              title: Text(playlist.title),
                              onTap: () {
                                _addToPlaylist(songInfo, playlist);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                        ],
                      )
                    ],
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _search() async {
    try {
      setState(() {
        _searching = true;
        _searchResults = [];
      });

      final query = _searchController.text;
      final url = '$_musicServerUrl/search?query=$query';

      Response response = await _dio.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to search.');
      }
      final results = response.data;

      final _songs = <Song>[];

      for (final item in results) {
        final song = Song(
          id: item['id'],
          title: item['title'],
          album: item['channel']['name'],
          artist: item['channel']['name'],
          remotePath: item['url'],
          localPath: '',
          songServerUrl: _musicServerUrl,
          isDownloaded: false,
          duration: Duration(),
          sizeInBytes: 0,
          artworkUrl: item['thumbnail'],
        );

        _songs.add(song);
      }
      setState(() {
        _searching = false;
        _searchResults = _songs;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search.'),
        ),
      );
      setState(() {
        _searching = false;
        _searchResults = [];
      });
    }
  }

  void _showOptionsModal(Song songInfo) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(songInfo.title),
                      Text(songInfo.album),
                      Text(songInfo.remotePath),
                      Text(songInfo.songServerUrl),
                      Image(
                        image: NetworkImage(songInfo.artworkUrl),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showPlaylistsModal(songInfo);
                      },
                      child: Text('Add to Playlist'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
          onSubmitted: (value) => _search(),
        ),
      ),
      body: _searching
          ? Center(child: CircularProgressIndicator())
          : _searchResults.isNotEmpty
              ? ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    final songItem = _searchResults[index];
                    return ListTile(
                      title: Text(songItem.title),
                      onTap: () => _showOptionsModal(songItem),
                    );
                  },
                )
              : Center(
                  child: Text('No results found.'),
                ),
    );
  }
}
