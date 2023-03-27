import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/playlist.dart';
import '../../models/song.dart';
import '../../services/page_manager.dart';
import '../../services/playlist_service.dart';
import '../../services/service_locator.dart';
import 'add_song_page.dart';

class PlaylistPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistPage({Key? key, required this.playlist}) : super(key: key);

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  late Playlist _playlist;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _playlistJson = prefs.getString(widget.playlist.id);
    if (_playlistJson != null) {
      setState(() {
        _playlist = Playlist.fromJson(jsonDecode(_playlistJson));
      });
    } else {
      // If the playlist doesn't exist, create an empty one
      setState(() {
        _playlist = Playlist(
          id: widget.playlist.id,
          title: widget.playlist.title,
          songs: [],
        );
      });
      _savePlaylist();
    }
  }

  Future<void> _savePlaylist() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(widget.playlist.id, jsonEncode(_playlist.toJson()));
  }

  void _addSong() async {
    final _song = await Navigator.push<Song>(
      context,
      MaterialPageRoute(
        builder: (context) => AddSongPage(),
      ),
    );
    if (_song != null) {
      setState(() {
        _playlist.addSong(_song);
      });
      await _savePlaylist();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Song added!')),
      );
    }
  }

  void _removeSong(String songId) {
    setState(() {
      _playlist.removeSong(songId);
    });
    _savePlaylist();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Song removed!')),
    );
  }

  Future<void> _playPlaylist() async {
    //TODO: Add all the musics to the queue
    // Currently its only defining the playlist as the current one and you should restart the app to play it
    final _pageManager = getIt<PageManager>();
    String playlistId = _playlist.id;

    // _playlistService.loadPlaylist();

    print("Play playlist $playlistId");
    _pageManager.playNewPlaylist(_playlist);

    // TODO: try to move this responsability to the page manager
    final _playlistService = GetIt.instance<PlaylistService>();
    await _playlistService.savePlaylist(_playlist);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement play button logic
                  _playPlaylist();
                },
                child: Text("Play"),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement play random button logic
                  _playPlaylist();
                },
                child: Text("Play random"),
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                itemCount: _playlist.songs.length,
                itemBuilder: (BuildContext context, int index) {
                  final _song = _playlist.songs[index];
                  return Dismissible(
                    key: Key(_song.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => _removeSong(_song.id),
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(_song.title),
                      subtitle: Text(_song.artist),
                      trailing: Text(
                        _song.duration.inMinutes.remainder(60).toString() +
                            ':' +
                            _song.duration.inSeconds
                                .remainder(60)
                                .toString()
                                .padLeft(2, '0'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSong,
        child: Icon(Icons.add),
      ),
    );
  }
}
