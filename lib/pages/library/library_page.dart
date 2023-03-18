import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/library.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import 'add_song_page.dart';
import 'playlist_page.dart';

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
          title: Text('New Playlist Name'),
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
          content: Text(
              'Are you sure you want to delete the playlist ${playlist.title}? This action cannot be undone.  \n\nThe downloaded musics will not be deleted from your device! You will be able to find them in the "Downloads" section.'),
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

