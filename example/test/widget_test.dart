import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards_example/main.dart';

void main() {
  testWidgets('Flashcard Studio welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashcardsExampleApp());

    // Verify that the welcome screen is shown with correct content
    expect(find.text('Flashcard Studio'), findsOneWidget);
    expect(find.text('Start Studying'), findsOneWidget);
    expect(find.text('Note: Running in standalone mode using in-memory mock repository. Easily swap to FirestoreFlashcardRepository in main.dart.'), findsOneWidget);
  });
}
