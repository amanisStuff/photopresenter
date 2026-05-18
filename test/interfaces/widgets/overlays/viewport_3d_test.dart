import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopresenter/interfaces/widgets/overlays/viewport_3d.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _makeTestable() {
    return const ProviderScope(
      child: MaterialApp(home: Scaffold(body: Viewport3D())),
    );
  }

  group('Viewport3D', () {
    testWidgets('builds with default state', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      expect(find.byType(Viewport3D), findsOneWidget);
    });

    testWidgets('shows light lock button', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('shows size panel button', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      expect(find.byIcon(Icons.aspect_ratio), findsOneWidget);
    });

    testWidgets('shows code button', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      expect(find.byIcon(Icons.code), findsOneWidget);
    });

    testWidgets('tapping size button opens size panel', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.aspect_ratio));
      await tester.pump();
      expect(find.text('Lock Size'), findsOneWidget);
    });

    testWidgets('size panel has lock switch', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      await tester.tap(find.byIcon(Icons.aspect_ratio));
      await tester.pump();
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('tapping light button toggles lock state', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pump();
      final lightButton = find.byIcon(Icons.lightbulb_outline);
      await tester.tap(lightButton);
      await tester.pump();
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });
  });
}
