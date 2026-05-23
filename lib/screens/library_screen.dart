// library_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final tabs = ['Listas', 'Álbumes', 'Artistas', 'Descargas'];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Biblioteca'),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ],
          bottom: TabBar(
            tabs: tabs.map((t) => Tab(text: t)).toList(),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
          ),
        ),
        body: TabBarView(
          children: [
            _PlaylistsTab(),
            _AlbumsTab(),
            _ArtistsTab(),
            _DownloadsTab(),
          ],
        ),
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LibraryItem(
          icon: Icons.thumb_up_outlined,
          title: 'Canciones que me gustan',
          subtitle: '0 canciones',
          color: Colors.blue,
        ),
        _LibraryItem(
          icon: Icons.download_done,
          title: 'Descargas',
          subtitle: '0 canciones',
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.library_music_outlined, size: 64),
                SizedBox(height: 16),
                Text('Tus listas aparecerán aquí'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const _EmptyState(
      icon: Icons.album, message: 'Tus álbumes guardados aparecerán aquí');
}

class _ArtistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const _EmptyState(
      icon: Icons.person_outline,
      message: 'Los artistas que sigues aparecerán aquí');
}

class _DownloadsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const _EmptyState(
      icon: Icons.download_outlined,
      message: 'Las canciones descargadas aparecerán aquí');
}

class _LibraryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _LibraryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
