import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photopresenter/main.dart';

void main() {
  testWidgets('App builds and shows empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PhotoPresenterApp(),
      ),
    );

    expect(find.text('Drag & Drop images or Paste (Ctrl+V)'), findsOneWidget);
  });


}
