import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards_example/main.dart';

void main() {
  testWidgets('Flashcard Studio welcome screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashcardsExampleApp());

    // Verify that the welcome screen is shown with correct content
    expect(find.text('Aquarium Academy'), findsOneWidget);
    expect(find.text('Review Animals & Facts'), findsOneWidget);
    expect(find.text('Note: Running in standalone mode using local mock data. Easily swap to FirestoreFlashcardRepository in main.dart.'), findsOneWidget);
  });
}
