import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Explore Screen ──────────────────────────────────────────────────────────

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Tendencias'),
          const SizedBox(height: 8),
          ...List.generate(5, (i) => _TrendingTile(rank: i + 1)),
          const SizedBox(height: 24),
          _SectionTitle('Géneros populares'),
          const SizedBox(height: 8),
          _GenreGrid(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _TrendingTile extends StatelessWidget {
  final int rank;
  const _TrendingTile({required this.rank});

  final List<Map<String, String>> _tracks = const [
    {'title': 'Flowers', 'artist': 'Miley Cyrus'},
    {'title': 'Shakira: Bzrp Music Sessions', 'artist': 'Bizarrap'},
    {'title': 'Quevedo: Bzrp Music Sessions', 'artist': 'Bizarrap'},
    {'title': 'As It Was', 'artist': 'Harry Styles'},
    {'title': 'Unholy', 'artist': 'Sam Smith'},
  ];

  @override
  Widget build(BuildContext context) {
    final track = _tracks[rank - 1];
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: SizedBox(
        width: 36,
        child: Text(
          '$rank',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ),
      title: Text(track['title']!),
      subtitle: Text(track['artist']!),
      trailing: const Icon(Icons.more_vert),
    );
  }
}

class _GenreGrid extends StatelessWidget {
  final List<(String, Color)> _genres = const [
    ('Pop', Colors.pink),
    ('Rock', Colors.red),
    ('Hip-Hop', Colors.orange),
    ('Electrónica', Colors.blue),
    ('Reggaeton', Colors.green),
    ('R&B', Colors.purple),
    ('Clásica', Colors.brown),
    ('Jazz', Colors.amber),
    ('Salsa', Colors.deepOrange),
    ('Indie', Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3,
      ),
      itemCount: _genres.length,
      itemBuilder: (context, index) {
        final (name, color) = _genres[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            alignment: Alignment.center,
            child: Text(name,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }
}

// ─── Playlist Screen ─────────────────────────────────────────────────────────

class PlaylistScreen extends ConsumerWidget {
  final String playlistId;
  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de reproducción')),
      body: const Center(child: Text('Cargando lista...')),
    );
  }
}

// ─── Artist Screen ────────────────────────────────────────────────────────────

class ArtistScreen extends ConsumerWidget {
  final String artistId;
  const ArtistScreen({super.key, required this.artistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artista')),
      body: const Center(child: Text('Cargando artista...')),
    );
  }
}

// ─── Album Screen ─────────────────────────────────────────────────────────────

class AlbumScreen extends ConsumerWidget {
  final String albumId;
  const AlbumScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Álbum')),
      body: const Center(child: Text('Cargando álbum...')),
    );
  }
}

// ─── Settings Screen ──────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          _SettingsSection('Apariencia', [
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Tema'),
              subtitle: const Text('Sistema'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Color de acento'),
              trailing: CircleAvatar(
                radius: 12,
                backgroundColor: colorScheme.primary,
              ),
              onTap: () {},
            ),
          ]),
          _SettingsSection('Audio', [
            SwitchListTile(
              secondary: const Icon(Icons.volume_up_outlined),
              title: const Text('Normalización de volumen'),
              value: true,
              onChanged: (_) {},
            ),
            SwitchListTile(
              secondary: const Icon(Icons.skip_next_outlined),
              title: const Text('Omitir silencios'),
              value: false,
              onChanged: (_) {},
            ),
          ]),
          _SettingsSection('Privacidad', [
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Historial de reproducción'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Limpiar caché'),
              onTap: () {},
            ),
          ]),
          _SettingsSection('Acerca de', [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Versión'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Código fuente'),
              subtitle: const Text('github.com/Arturo254/OpenTune'),
              onTap: () {},
            ),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
