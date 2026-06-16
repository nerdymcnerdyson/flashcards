import '../models/flashcard.dart';

abstract class FlashcardRepository {
  /// Returns a stream of available flashcards.
  Stream<List<Flashcard>> getFlashcards();

  /// Updates the stats (correct count / total count) for a specific card.
  Future<void> updateFlashcardStats(String cardId, {required bool isCorrect});
}
