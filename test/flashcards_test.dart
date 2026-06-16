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

    test('copyWith works correctly with SM-2 parameters', () {
      final reviewDate = DateTime(2026, 6, 16);
      const card = Flashcard(
        id: '1',
        question: 'Q',
        answer: 'A',
        correctCount: 2,
        totalCount: 5,
        easinessFactor: 2.4,
        repetitions: 2,
        intervalDays: 6,
      );

      final updated = card.copyWith(
        correctCount: 3,
        totalCount: 6,
        easinessFactor: 2.5,
        repetitions: 3,
        intervalDays: 15,
        nextReviewAt: reviewDate,
      );

      expect(updated.id, '1');
      expect(updated.correctCount, 3);
      expect(updated.totalCount, 6);
      expect(updated.easinessFactor, 2.5);
      expect(updated.repetitions, 3);
      expect(updated.intervalDays, 15);
      expect(updated.nextReviewAt, reviewDate);
    });

    test('toMap and fromMap serialization matches with SM-2 parameters', () {
      final reviewDate = DateTime(2026, 6, 16, 12, 0, 0);
      final card = Flashcard(
        id: '1',
        question: 'Question',
        answer: 'Answer',
        imageUrl: 'https://example.com/img.png',
        hints: ['Hint 1', 'Hint 2'],
        multipleChoiceOptions: ['Option A', 'Answer', 'Option B'],
        correctCount: 2,
        totalCount: 3,
        easinessFactor: 2.3,
        repetitions: 4,
        intervalDays: 10,
        nextReviewAt: reviewDate,
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
      expect(reconstructed.easinessFactor, card.easinessFactor);
      expect(reconstructed.repetitions, card.repetitions);
      expect(reconstructed.intervalDays, card.intervalDays);
      expect(reconstructed.nextReviewAt, card.nextReviewAt);
    });
  });

  group('SM-2 Algorithm Simulation (Mock Repository) Tests', () {
    test('Incorrect review resets interval & repetitions, reduces EF', () async {
      final repo = MockFlashcardRepository(userId: 'test_srs_user');
      
      // Initially, card '1' has no stats (new card), should default: EF = 2.5, reps = 0, interval = 0
      var cardsList = await repo.getFlashcards().first;
      var card = cardsList.firstWhere((c) => c.id == '1');
      expect(card.repetitions, 0);
      expect(card.easinessFactor, 2.5);
      
      // Study Incorrect
      await repo.updateFlashcardStats('1', isCorrect: false);
      
      cardsList = await repo.getFlashcards().first;
      card = cardsList.firstWhere((c) => c.id == '1');
      
      expect(card.repetitions, 0);
      expect(card.intervalDays, 1);
      expect(card.easinessFactor, 2.3); // 2.5 - 0.2
      expect(card.nextReviewAt, isNotNull);
      expect(card.nextReviewAt!.isAfter(DateTime.now()), isTrue);
    });

    test('Correct reviews consecutively increments repetitions & calculates intervals', () async {
      final repo = MockFlashcardRepository(userId: 'test_srs_user_2');

      // 1. First Correct review: reps = 0 -> interval = 1
      await repo.updateFlashcardStats('1', isCorrect: true);
      var cards = await repo.getFlashcards().first;
      var card = cards.firstWhere((c) => c.id == '1');
      expect(card.repetitions, 1);
      expect(card.intervalDays, 1);
      expect(card.easinessFactor, 2.6); // 2.5 + 0.1

      // 2. Second Correct review: reps = 1 -> interval = 6
      await repo.updateFlashcardStats('1', isCorrect: true);
      cards = await repo.getFlashcards().first;
      card = cards.firstWhere((c) => c.id == '1');
      expect(card.repetitions, 2);
      expect(card.intervalDays, 6);
      expect(card.easinessFactor, 2.7); // 2.6 + 0.1

      // 3. Third Correct review: reps = 2 -> interval = 6 * 2.7 = 16 (rounded from 16.2)
      await repo.updateFlashcardStats('1', isCorrect: true);
      cards = await repo.getFlashcards().first;
      card = cards.firstWhere((c) => c.id == '1');
      expect(card.repetitions, 3);
      expect(card.intervalDays, 16);
      expect(card.easinessFactor, 2.8); // 2.7 + 0.1
    });
  });
}
