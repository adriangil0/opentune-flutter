import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../providers/player_provider.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final notifier = ref.read(audioPlayerProvider.notifier);
    final song = playerState.currentSong;

    if (song == null) {
      context.pop();
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.4),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),
              _buildAlbumArt(context, song),
              const SizedBox(height: 32),
              _buildSongInfo(context, ref, song, colorScheme),
              const SizedBox(height: 16),
              _buildProgressBar(context, ref, playerState, notifier),
              const SizedBox(height: 16),
              _buildControls(context, ref, playerState, notifier, colorScheme),
              const SizedBox(height: 24),
              _buildBottomActions(context, playerState, colorScheme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'Reproduciendo ahora',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(BuildContext context, song) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AspectRatio(
        aspectRatio: 1,
        child: Hero(
          tag: 'album-art-${song.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: song.thumbnailHighRes,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.music_note, size: 80),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.music_note, size: 80),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, WidgetRef ref, song, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            iconSize: 28,
            color: colorScheme.onSurfaceVariant,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, WidgetRef ref,
      PlayerState playerState, AudioPlayerNotifier notifier) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerHighest,
              thumbColor: colorScheme.primary,
            ),
            child: Slider(
              value: playerState.progress.clamp(0.0, 1.0),
              onChanged: notifier.seekToProgress,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(playerState.position),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  _formatDuration(playerState.duration),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref,
      PlayerState playerState, AudioPlayerNotifier notifier, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: playerState.isShuffled
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            iconSize: 26,
            onPressed: notifier.toggleShuffle,
          ),

          // Previous
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            iconSize: 40,
            onPressed: notifier.playPrevious,
          ),

          // Play/Pause
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary,
            ),
            child: playerState.isLoading
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 3,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      playerState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: colorScheme.onPrimary,
                      size: 40,
                    ),
                    onPressed: notifier.togglePlayPause,
                  ),
          ),

          // Next
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            iconSize: 40,
            onPressed: notifier.playNext,
          ),

          // Loop
          IconButton(
            icon: Icon(
              playerState.loopMode == LoopModeState.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: playerState.loopMode != LoopModeState.off
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            iconSize: 26,
            onPressed: notifier.cycleLoopMode,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, PlayerState playerState, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.lyrics_outlined,
            label: 'Letra',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.queue_music_rounded,
            label: 'Cola',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.download_outlined,
            label: 'Descargar',
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Compartir',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
