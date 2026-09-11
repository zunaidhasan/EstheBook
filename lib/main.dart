import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/presentation/eb_router.dart';
import 'src/core/theme/eb_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EstheBookApp()));
}

/// Root widget: wires the design system and go_router navigation.
class EstheBookApp extends ConsumerWidget {
  const EstheBookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(ebRouterProvider);

    return MaterialApp.router(
      title: 'EstheBook',
      debugShowCheckedModeBanner: false,
      theme: buildEbTheme(),
      routerConfig: router,
    );
  }
}
