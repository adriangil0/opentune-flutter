import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

import '../services/innertube_service.dart';

// ─── State ──────────────────────────────────────────────────────────────────

class PlayerState {
  final SongItem? currentSong;
  final List<SongItem> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffled;
  final LoopModeState loopMode;
  final String? errorMessage;

  const PlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffled = false,
    this.loopMode = LoopModeState.off,
    this.errorMessage,
  });

  PlayerState copyWith({
    SongItem? currentSong,
    List<SongItem>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffled,
    LoopModeState? loopMode,
    String? errorMessage,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffled: isShuffled ?? this.isShuffled,
      loopMode: loopMode ?? this.loopMode,
      errorMessage: errorMessage,
    );
  }

  double get progress =>
      duration.inMilliseconds > 0
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0;
}

enum LoopModeState { off, all, one }

// ─── Provider ────────────────────────────────────────────────────────────────

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, PlayerState>((ref) {
  return AudioPlayerNotifier(ref);
});

class AudioPlayerNotifier extends StateNotifier<PlayerState> {
  final Ref _ref;
  final AudioPlayer _player;
  final InnerTubeService _innerTube;

  AudioPlayerNotifier(this._ref)
      : _player = AudioPlayer(),
        _innerTube = InnerTubeService(),
        super(const PlayerState()) {
    _init();
  }

  Future<void> _init() async {
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state changes
    _player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });

    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _playNext();
      }
    });
  }

  Future<void> playSong(SongItem song, {List<SongItem>? queue}) async {
    try {
      state = state.copyWith(
        currentSong: song,
        isLoading: true,
        errorMessage: null,
        queue: queue ?? [song],
        currentIndex: queue?.indexOf(song) ?? 0,
      );

      final info = await _innerTube.getSongInfo(song.id);

      if (info.bestAudioUrl == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudo obtener el audio',
        );
        return;
      }

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(info.bestAudioUrl!),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.artist,
            album: song.album,
            artUri: song.thumbnailUrl != null
                ? Uri.parse(song.thumbnailHighRes)
                : null,
          ),
        ),
      );

      await _player.play();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al reproducir: $e',
      );
    }
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void seek(Duration position) {
    _player.seek(position);
  }

  void seekToProgress(double progress) {
    final duration = state.duration;
    final position = Duration(
      milliseconds: (progress * duration.inMilliseconds).round(),
    );
    seek(position);
  }

  Future<void> _playNext() async {
    final queue = state.queue;
    final nextIndex = state.currentIndex + 1;

    if (nextIndex < queue.length) {
      await playSong(queue[nextIndex], queue: queue);
      state = state.copyWith(currentIndex: nextIndex);
    } else if (state.loopMode == LoopModeState.all && queue.isNotEmpty) {
      await playSong(queue[0], queue: queue);
      state = state.copyWith(currentIndex: 0);
    }
  }

  Future<void> playNext() => _playNext();

  Future<void> playPrevious() async {
    // If more than 3s in, restart song
    if (state.position.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }

    final prevIndex = state.currentIndex - 1;
    if (prevIndex >= 0) {
      await playSong(state.queue[prevIndex], queue: state.queue);
      state = state.copyWith(currentIndex: prevIndex);
    }
  }

  void toggleShuffle() {
    final shuffled = !state.isShuffled;
    state = state.copyWith(isShuffled: shuffled);
    _player.setShuffleModeEnabled(shuffled);
  }

  void cycleLoopMode() {
    final modes = LoopModeState.values;
    final nextMode = modes[(state.loopMode.index + 1) % modes.length];
    state = state.copyWith(loopMode: nextMode);

    switch (nextMode) {
      case LoopModeState.off:
        _player.setLoopMode(LoopMode.off);
        break;
      case LoopModeState.all:
        _player.setLoopMode(LoopMode.all);
        break;
      case LoopModeState.one:
        _player.setLoopMode(LoopMode.one);
        break;
    }
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
