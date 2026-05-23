import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/innertube_service.dart';
import '../providers/player_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.family<SearchResult, String>((ref, query) async {
  if (query.isEmpty) return const SearchResult(songs: [], artists: [], albums: []);
  final service = InnerTubeService();
  return service.search(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: SearchBar(
              controller: _controller,
              focusNode: _focusNode,
              hintText: 'Buscar canciones, artistas, álbumes...',
              leading: const Icon(Icons.search),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  ),
              ],
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          if (query.isEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSearchSuggestions(context),
            ),
          ] else ...[
            _buildSearchResults(context, ref, query),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      ('Éxitos', Icons.trending_up, Colors.purple),
      ('Pop', Icons.music_note, Colors.pink),
      ('Rock', Icons.electric_guitar, Colors.red),
      ('Hip-Hop', Icons.mic, Colors.orange),
      ('Electrónica', Icons.equalizer, Colors.blue),
      ('Reggaeton', Icons.star, Colors.green),
      ('Clásica', Icons.piano, Colors.brown),
      ('Jazz', Icons.saxophone, Colors.amber),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explorar categorías',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final (name, icon, color) = categories[index];
              return InkWell(
                onTap: () {
                  _controller.text = name;
                  ref.read(searchQueryProvider.notifier).state = name;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, WidgetRef ref, String query) {
    final resultsAsync = ref.watch(searchResultsProvider(query));

    return resultsAsync.when(
      data: (results) {
        if (results.songs.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(Icons.search_off,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('Sin resultados para "$query"'),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _SongTile(song: results.songs[index]),
            childCount: results.songs.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Text('Error: $e'),
          ),
        ),
      ),
    );
  }
}

class _SongTile extends ConsumerWidget {
  final SongItem song;
  const _SongTile({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: song.thumbnailHighRes,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.music_note),
          ),
          errorWidget: (_, __, ___) => Container(
            color: colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.music_note),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showOptions(context, ref),
      ),
      onTap: () {
        ref.read(audioPlayerProvider.notifier).playSong(song);
      },
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Reproducir'),
            onTap: () {
              Navigator.pop(context);
              ref.read(audioPlayerProvider.notifier).playSong(song);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Agregar a cola'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Me gusta'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartir'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Descargar'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
