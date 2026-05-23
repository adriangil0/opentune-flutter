import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/player_provider.dart';
import 'mini_player.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerProvider);
    final hasTrack = playerState.currentSong != null;

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          if (hasTrack) const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: _NavBar(),
    );
  }
}

class _NavBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;

    int selectedIndex = 0;
    if (location.startsWith('/search')) selectedIndex = 1;
    if (location.startsWith('/explore')) selectedIndex = 2;
    if (location.startsWith('/library')) selectedIndex = 3;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/search'); break;
          case 2: context.go('/explore'); break;
          case 3: context.go('/library'); break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Buscar',
        ),
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        NavigationDestination(
          icon: Icon(Icons.library_music_outlined),
          selectedIcon: Icon(Icons.library_music),
          label: 'Biblioteca',
        ),
      ],
    );
  }
}
