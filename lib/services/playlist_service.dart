import '../models/playlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistService {
  static const String _playlistArrayKey = 'lastPlaylistId';

  Future<void> savePlaylist(Playlist playlist) async {
    print('>>>> savePlaylist()');
    final Playlist _newPlaylist = await playlist.load();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playlistArrayKey, _newPlaylist.id);
    await _newPlaylist.save();
  }

  Future<Playlist> loadLastPlayedPlaylist() async {
    print('>>>> loadPlaylist()');
    final prefs = await SharedPreferences.getInstance();
    final lastPlaylistId = prefs.getString(_playlistArrayKey);
    if (lastPlaylistId == null) {
      return Playlist(
        id: '',
        title: '',
        songs: [],
      );
    }
    final Playlist playlist = await Playlist(
      id: lastPlaylistId,
      title: '',
      songs: [],
    ).load();
    return playlist;
  }

  Future<void> clearLastPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playlistArrayKey);
  }

  // Future<void> addSong(Song song) async {
  //   final playlist = await loadPlaylist();
  //   playlist.add(song);
  //   await savePlaylist(playlist);
  // }

  // Future<void> removeSong(Song song) async {
  //   final playlist = await loadPlaylist();
  //   playlist.remove(song);
  //   await savePlaylist(playlist);
  // }

  Future<void> printPlaylist() async {
    final Playlist playlist = await loadLastPlayedPlaylist();
    print(playlist);
  }
}
