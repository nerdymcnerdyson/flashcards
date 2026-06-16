import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards/flashcards.dart';

void main() {
  group('Flashcard Model Tests', () {
    test('Calculates accuracy correctly', () {
      const card = Flashcard(
        id: '1',
        question: 'Q',
        answer: 'A',
        correctCount: 3,
        totalCount: 4,
      );

      expect(card.accuracy, 0.75);
      expect(card.accuracyPercentageString, '75.0%');
    });

    test('Handles zero total count accuracy correctly', () {
      const card = Flashcard(
        id: '1',
        question: 'Q',
        answer: 'A',
        correctCount: 0,
        totalCount: 0,
      );

      expect(card.accuracy, 0.0);
      expect(card.accuracyPercentageString, '0%');
    });

    test('copyWith works correctly', () {
      const card = Flashcard(
        id: '1',
        question: 'Q',
        answer: 'A',
        correctCount: 2,
        totalCount: 5,
      );

      final updated = card.copyWith(correctCount: 3, totalCount: 6);

      expect(updated.id, '1');
      expect(updated.question, 'Q');
      expect(updated.answer, 'A');
      expect(updated.correctCount, 3);
      expect(updated.totalCount, 6);
      expect(updated.accuracy, 0.5);
    });

    test('toMap and fromMap serialization matches', () {
      final card = Flashcard(
        id: '1',
        question: 'Question',
        answer: 'Answer',
        imageUrl: 'https://example.com/img.png',
        hints: ['Hint 1', 'Hint 2'],
        multipleChoiceOptions: ['Option A', 'Answer', 'Option B'],
        correctCount: 2,
        totalCount: 3,
      );

      final map = card.toMap();
      final reconstructed = Flashcard.fromMap(map, '1');

      expect(reconstructed.id, card.id);
      expect(reconstructed.question, card.question);
      expect(reconstructed.answer, card.answer);
      expect(reconstructed.imageUrl, card.imageUrl);
      expect(reconstructed.hints, card.hints);
      expect(reconstructed.multipleChoiceOptions, card.multipleChoiceOptions);
      expect(reconstructed.correctCount, card.correctCount);
      expect(reconstructed.totalCount, card.totalCount);
    });
  });
}
