import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards/flashcards.dart';

void main() {
  const testCard = Flashcard(
    id: 'test_1',
    question: 'What is the capital of France?',
    answer: 'Paris',
    hints: ['Starts with P'],
    multipleChoiceOptions: ['Berlin', 'London', 'Paris', 'Madrid'],
    correctCount: 0,
    totalCount: 0,
  );

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('FlashcardCard Widget Tests', () {
    testWidgets('Displays question and show hint button initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          FlashcardCard(
            flashcard: testCard,
            onAnswered: (_) {},
          ),
        ),
      );

      // Question is shown
      expect(find.text('What is the capital of France?'), findsOneWidget);

      // Answer is NOT shown initially
      expect(find.text('Paris'), findsNothing);

      // Hint button is shown
      expect(find.text('Show Multiple Choice Hint'), findsOneWidget);

      // Options are NOT shown yet
      expect(find.text('Berlin'), findsNothing);
      expect(find.text('London'), findsNothing);
    });

    testWidgets('Reveals multiple choice options when clicking the hint button', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          FlashcardCard(
            flashcard: testCard,
            onAnswered: (_) {},
          ),
        ),
      );

      // Tap hint button
      await tester.tap(find.text('Show Multiple Choice Hint'));
      await tester.pumpAndSettle();

      // Options are now visible
      expect(find.text('Berlin'), findsOneWidget);
      expect(find.text('London'), findsOneWidget);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Madrid'), findsOneWidget);

      // Hint button should disappear
      expect(find.text('Show Multiple Choice Hint'), findsNothing);
    });

    testWidgets('Tapping a correct choice calls onAnswered with true', (WidgetTester tester) async {
      bool? answeredCorrectly;

      await tester.pumpWidget(
        buildTestableWidget(
          FlashcardCard(
            flashcard: testCard,
            onAnswered: (isCorrect) {
              answeredCorrectly = isCorrect;
            },
          ),
        ),
      );

      // Reveal options
      await tester.tap(find.text('Show Multiple Choice Hint'));
      await tester.pumpAndSettle();

      // Tap the correct answer (Paris)
      await tester.tap(find.text('Paris'));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(answeredCorrectly, isTrue);
    });

    testWidgets('Tapping incorrect choice calls onAnswered with false', (WidgetTester tester) async {
      bool? answeredCorrectly;

      await tester.pumpWidget(
        buildTestableWidget(
          FlashcardCard(
            flashcard: testCard,
            onAnswered: (isCorrect) {
              answeredCorrectly = isCorrect;
            },
          ),
        ),
      );

      // Reveal options
      await tester.tap(find.text('Show Multiple Choice Hint'));
      await tester.pumpAndSettle();

      // Tap an incorrect answer (Berlin)
      await tester.tap(find.text('Berlin'));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(answeredCorrectly, isFalse);
    });

    testWidgets('Card flips when clicking flip button to reveal answer', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          FlashcardCard(
            flashcard: testCard,
            onAnswered: (_) {},
          ),
        ),
      );

      // Tap flip text button
      await tester.tap(find.text('Tap to Flip & Reveal Answer'));
      await tester.pumpAndSettle();

      // Answer is now visible
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('ANSWER'), findsOneWidget);

      // Question is on the front, which is rotated 180 deg out of view
      // Under our flip widget, when isFront is false, the front content is not rendered,
      // so the question should not be found.
      expect(find.text('What is the capital of France?'), findsNothing);
    });
  });
}
