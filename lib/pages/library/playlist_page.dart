import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/library.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
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
    final playlistJson = prefs.getString(widget.playlist.id);
    if (playlistJson != null) {
      setState(() {
        _playlist = Playlist.fromJson(jsonDecode(playlistJson));
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.playlist.id, jsonEncode(_playlist.toJson()));
  }

  void _addSong() async {
    final song = await Navigator.push<Song>(
      context,
      MaterialPageRoute(
        builder: (context) => AddSongPage(),
      ),
    );
    if (song != null) {
      setState(() {
        _playlist.addSong(song);
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
                },
                child: Text("Play"),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement play random button logic
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
                  final song = _playlist.songs[index];
                  return Dismissible(
                    key: Key(song.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => _removeSong(song.id),
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
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      trailing: Text(
                        song.duration.inMinutes.remainder(60).toString() +
                            ':' +
                            song.duration.inSeconds
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
