import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../services/innertube_service.dart';
import '../providers/player_provider.dart';

final homeFeedProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = InnerTubeService();
  return service.getHomeFeed();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          feedAsync.when(
            data: (data) => _buildContent(context, ref, data),
            loading: () => _buildShimmer(context),
            error: (e, _) => SliverToBoxAdapter(
              child: _buildError(context, ref, e.toString()),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      floating: true,
      snap: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              'OpenTune',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cast_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(
          icon: CircleAvatar(
            radius: 14,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.person,
                size: 16, color: colorScheme.onPrimaryContainer),
          ),
          onPressed: () => context.push('/settings'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    // Quick picks chips
    return SliverList(
      delegate: SliverChildListDelegate([
        _QuickPicksSection(),
        const SizedBox(height: 8),
        _RecentlyPlayedSection(),
        const SizedBox(height: 8),
        _MoodSection(),
      ]),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 150, height: 20, color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12)),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (_, __) => Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Sin conexión',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Verifica tu conexión a internet',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.refresh(homeFeedProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Picks ────────────────────────────────────────────────────────────

class _QuickPicksSection extends ConsumerWidget {
  // Demo songs for UI
  final List<Map<String, String>> _demoSongs = const [
    {
      'id': 'dQw4w9WgXcQ',
      'title': 'Never Gonna Give You Up',
      'artist': 'Rick Astley',
      'thumb': 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg',
    },
    {
      'id': 'JGwWNGJdvx8',
      'title': 'Shape of You',
      'artist': 'Ed Sheeran',
      'thumb': 'https://img.youtube.com/vi/JGwWNGJdvx8/mqdefault.jpg',
    },
    {
      'id': 'kXYiU_JCYtU',
      'title': 'Numb',
      'artist': 'Linkin Park',
      'thumb': 'https://img.youtube.com/vi/kXYiU_JCYtU/mqdefault.jpg',
    },
    {
      'id': 'hT_nvWreIhg',
      'title': 'Counting Stars',
      'artist': 'OneRepublic',
      'thumb': 'https://img.youtube.com/vi/hT_nvWreIhg/mqdefault.jpg',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Selección rápida',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 72,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _demoSongs.length,
            itemBuilder: (context, index) {
              final song = _demoSongs[index];
              return _QuickPickChip(
                song: SongItem(
                  id: song['id']!,
                  title: song['title']!,
                  artist: song['artist']!,
                  thumbnailUrl: song['thumb'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickPickChip extends ConsumerWidget {
  final SongItem song;

  const _QuickPickChip({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        ref.read(audioPlayerProvider.notifier).playSong(song);
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: song.thumbnailHighRes,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recently Played ────────────────────────────────────────────────────────

class _RecentlyPlayedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final moods = [
      ('Energético', Icons.bolt, Colors.orange),
      ('Relajado', Icons.spa, Colors.teal),
      ('Feliz', Icons.sentiment_very_satisfied, Colors.yellow),
      ('Melancólico', Icons.nights_stay, Colors.indigo),
      ('Concentración', Icons.psychology, Colors.blue),
      ('Romántico', Icons.favorite, Colors.pink),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Escucha según tu estado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final (label, icon, color) = moods[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text(label),
                    ],
                  ),
                  onSelected: (_) {},
                  selected: false,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Mood Section ────────────────────────────────────────────────────────────

class _MoodSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      ('Éxitos', 'https://img.youtube.com/vi/JGwWNGJdvx8/mqdefault.jpg', Colors.purple),
      ('Pop', 'https://img.youtube.com/vi/kXYiU_JCYtU/mqdefault.jpg', Colors.pink),
      ('Rock', 'https://img.youtube.com/vi/hT_nvWreIhg/mqdefault.jpg', Colors.red),
      ('Hip-Hop', 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg', Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Text(
            'Categorías',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final (name, thumb, color) = categories[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: thumb,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
