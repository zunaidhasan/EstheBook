import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esthebook/main.dart';

void main() {
  testWidgets('app boots and shows the discovery screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EstheBookApp()));

    // Discovery header appears.
    expect(find.textContaining('Hi,'), findsOneWidget);

    // Let the mock repository future and mock latency resolve.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);
  });
}
