import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/library.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import 'add_song_page.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Playlist> _playlists = [];
  Library _library = Library();

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    List<Playlist> playlists = await _library.loadPlaylists();

    setState(() {
      _playlists = playlists;
    });
  }

  Future<void> _createPlaylist() async {
    TextEditingController _playlistNameController = TextEditingController();

    String? playlistName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Playlist'),
          content: TextField(controller: _playlistNameController),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () =>
                  Navigator.pop(context, _playlistNameController.text),
            ),
          ],
        );
      },
    );
    if (playlistName != null && playlistName.isNotEmpty) {
      Playlist playlist = await _library.createPlaylist(playlistName);

      setState(() {
        _playlists.add(playlist);
      });
    }
  }

  Future<void> _deletePlaylist(Playlist playlist) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this playlist?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    if (confirmDelete != null && confirmDelete) {
      bool success = await _library.deletePlaylist(playlist.id);
      print('>>> playlist deleted: $success');
      setState(() {
        _playlists.remove(playlist);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
      ),
      body: ListView.builder(
        itemCount: _playlists.length,
        itemBuilder: (BuildContext context, int index) {
          Playlist playlist = _playlists[index];
          return GestureDetector(
            onTap: () {
              print('>>> playlist tapped: ${playlist.title}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => PlaylistPage(
                    playlist: playlist,
                  ),
                ),
              );
            },
            onLongPress: () {
              print('>>> playlist long pressed: ${playlist.title}');
              _deletePlaylist(playlist);
            },
            child: Card(
              child: ListTile(
                leading: Hero(
                  tag: 'playlist_icon_$index',
                  child: Icon(Icons.queue_music),
                ),
                title: Text(playlist.title),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: Icon(Icons.add),
      ),
    );
  }
}

//TODO: Put this widget in its own file
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
    final playlistJson = prefs.getString(widget.playlist.title);
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
    print(">>> addSong");
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
      _savePlaylist();
    }
  }

  void _removeSong(String songId) {
    setState(() {
      _playlist.removeSong(songId);
    });
    _savePlaylist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist.title),
      ),
      body: ListView.builder(
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
              trailing: Text(song.duration.inMinutes.remainder(60).toString() +
                  ':' +
                  song.duration.inSeconds
                      .remainder(60)
                      .toString()
                      .padLeft(2, '0')),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSong,
        child: Icon(Icons.add),
      ),
    );
  }
}
