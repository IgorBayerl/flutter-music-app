import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.company.app.audio',
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);


  MyAudioHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    // Listen to playback events from the audio player
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;

      // Update the playback state to reflect the current status of the player
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          // Display "pause" if playing, "play" otherwise
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        // Allow seeking
        systemActions: const {
          MediaAction.seek,
        },
        // Compact actions: skip to previous, play/pause, skip to next
        androidCompactActionIndices: const [0, 1, 3],
        // Map the processing state of the player to the AudioService's processing state
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        // Map the loop mode of the player to the AudioService's repeat mode
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        // Enable shuffle mode if the player's shuffle mode is enabled
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        // Update the current position of the player
        updatePosition: _player.position,
        // Update the buffered position of the player
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        // Update the current index in the queue
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    // Listen for changes in the duration of the audio player
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;

      // If there's no current index or the queue is empty, return
      if (index == null || newQueue.isEmpty) return;

      // If shuffle mode is enabled, get the shuffled index
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }

      // Get the current media item in the queue
      final oldMediaItem = newQueue[index];
      // Create a new media item with the updated duration
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      // Replace the old media item in the queue with the new one
      newQueue[index] = newMediaItem;
      // Update the queue and the media item
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    // Listen for changes in the current song index
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;

      // If there's no current index or the playlist is empty, return
      if (index == null || playlist.isEmpty) return;

      // If shuffle mode is enabled, get the shuffled index
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }

      // Update the current media item
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    // Listen for changes in the sequence state of the audio player
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;

      // If the sequence is empty, return
      if (sequence == null || sequence.isEmpty) return;

      // Convert the sources in the sequence to media items
      final items = sequence.map((source) => source.tag as MediaItem);
      // Update the queue
      queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> mediaItems) async {
    _playlist.clear();
    await addQueueItems(mediaItems);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    final remotePath = mediaItem.extras!['remotePath'] as String;
    final localPath = mediaItem.extras!['localPath'] as String;

    final uri =
        localPath.isNotEmpty ? Uri.parse(localPath) : Uri.parse(remotePath);

    print(">>>> _createAudioSource remotePath: $uri");
    return AudioSource.uri(
      uri,
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);

    final newQueue = queue.value;
    newQueue[index] = mediaItem;
    queue.add(newQueue);
  }
}
