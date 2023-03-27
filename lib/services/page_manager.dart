import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
// import 'playlist_repository.dart';
import 'playlist_service.dart';
import 'service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentPlaylistNotifier = ValueNotifier<Playlist>(Playlist.empty());

  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();

  // Events: Calls coming from the UI
  void init() async {
    await _loadLastPlayedPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> _loadLastPlayedPlaylist() async {
    final playlistService = GetIt.instance<PlaylistService>();
    final playlist = await playlistService.loadLastPlayedPlaylist();

    print('Playlist loaded: ${playlist.songs.length} songs');
    final mediaItemsFutures = playlist.songs.map((song) async {
      await song.initializeLocalPath();
      return song.toMediaItem();
    }).toList();

    final mediaItems = await Future.wait(mediaItemsFutures);
    // await Future.delayed(Duration(milliseconds: 500));
    _audioHandler.updateQueue(mediaItems);
  }

  // Future<void> updateSongDownloadState(Song song) async {
  //   final _currentPlaylist = currentPlaylistNotifier.value;
  //   final index =
  //       _currentPlaylist.songs.indexWhere((element) => element.id == song.id);

  //   await song.initializeLocalPath();
  //   _currentPlaylist.songs[index] = song;

  //   currentPlaylistNotifier.value = _currentPlaylist;

  //   //update in the queue
  //   final mediaItem = song.toMediaItem();
  //   await _audioHandler.updateMediaItem(mediaItem);
  // }

  void logPlaylist() {
    print('Playlist: ${_audioHandler.queue.value.length} songs');
    currentPlaylistNotifier.value.songs.forEach((song) {
      print(song.isDownloaded.toString() + ' - ' + song.title);
    });
  }

  void playNewPlaylist(Playlist playlist) async {
    // clearQueue();

    List<MediaItem> _mediaItems = playlist.songs.map((song) {
      return song.toMediaItem();
    }).toList();

    // currentPlaylistNotifier.value = playlist;

    // await _audioHandler.addQueueItems(_mediaItems);

    // // TODO: investigate why this is needed
    // // wait half a second and play, otherwise the player will not start

    _audioHandler.updateQueue(_mediaItems);
    await Future.delayed(Duration(milliseconds: 500));
    await _audioHandler.play();
  }

  // static void _updateLocalPlaylist(Playlist playlist) async {
  //   PlaylistService _playlistService = GetIt.instance<PlaylistService>();
  //   _playlistService.savePlaylist(playlist);
  // }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((List<MediaItem> queue) {
      print("QUEUE CHANGED");
      final List<Song> _songs =
          queue.map((mediaItem) => Song.fromMediaItem(mediaItem)).toList();

      final Playlist playlist = Playlist.empty();
      playlist.songs.addAll(_songs);
      currentPlaylistNotifier.value = playlist;

      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      // Update the play button based on the current state
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        // If the player is loading or buffering, the play button state should show loading
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        // If the player is not playing, the play button state should show paused
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        // If the player is playing and the processing state is not completed, the play button state should show playing
        playButtonNotifier.value = ButtonState.playing;
      } else {
        // If the player has completed processing, reset the player to the start and pause it
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      _updateSkipButtons();
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  void remove() {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    _audioHandler.removeQueueItemAt(lastIndex);
  }

  void clearQueue() async {
    final _playlistLength = _audioHandler.queue.value.length + 1;
    for (var i = 0; i < _playlistLength; i++) {
      remove();
    }
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }

  void playFromMediaIndex(int mediaIndex) async {
    await _audioHandler.skipToQueueItem(mediaIndex);
    _audioHandler.play();

    final logItem = _audioHandler.queue.value[mediaIndex];
    //log media item path
    print('>>>>>> playFromMediaIndex.logItem $logItem');
  }

  Future<void> updateMediaItem(Song song) async {
    final _item = song.toMediaItem();

    await _audioHandler.updateMediaItem(_item);
    print('>>>>>> logTest');
  }
}
