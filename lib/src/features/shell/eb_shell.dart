import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/eb_theme.dart';

/// Scaffold with adaptive navigation — [NavigationBar] on narrow layouts,
/// [NavigationRail] on wide screens (e.g. desktop browser via Pages).
class EbShell extends ConsumerStatefulWidget {
  const EbShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<EbShell> createState() => _EbShellState();
}

class _EbShellState extends ConsumerState<EbShell> {
  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/bookings')) return 1;
    return 0;
  }

  void _onDestinationSelected(int i, GoRouter router) {
    switch (i) {
      case 0:
        router.go('/discover');
        break;
      case 1:
        router.go('/bookings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final index = _selectedIndex(context);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    const destinations = [
      (icon: Icons.explore_outlined, selectedIcon: Icons.explore, label: 'Discover'),
      (icon: Icons.event_note_outlined, selectedIcon: Icons.event_note, label: 'My Bookings'),
    ];

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => _onDestinationSelected(i, router),
              labelType: NavigationRailLabelType.all,
              backgroundColor: EbColors.card,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: EbColors.blush,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('🌸', style: TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'EstheBook',
                      style: TextStyle(
                        fontFamily: 'Georgia, serif',
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: EbColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              destinations: [
                for (final d in destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onDestinationSelected(i, router),
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
