import 'dart:async';
import '../models/flashcard.dart';
import 'flashcard_repository.dart';

class MockFlashcardRepository implements FlashcardRepository {
  final List<Flashcard> _cards = [
    Flashcard(
      id: '1',
      question: 'What is the capital of Japan?',
      answer: 'Tokyo',
      imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?w=500&auto=format&fit=crop&q=60',
      hints: ['It starts with T', "It's the most populous metropolitan area in the world."],
      multipleChoiceOptions: ['Kyoto', 'Osaka', 'Tokyo', 'Hiroshima'],
      correctCount: 4,
      totalCount: 5,
    ),
    Flashcard(
      id: '2',
      question: 'Which Flutter widget allows you to perform 3D rotations or perspective shifts on its child?',
      answer: 'Transform',
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=60',
      hints: ['It uses Matrix4 for coordinates transformation.', 'You can combine it with AnimatedBuilder.'],
      multipleChoiceOptions: ['Rotate', 'Transform', 'Skew', 'MatrixWidget'],
      correctCount: 2,
      totalCount: 3,
    ),
    Flashcard(
      id: '3',
      question: 'What programming language is Flutter written in and compiles to?',
      answer: 'Dart',
      imageUrl: 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop&q=60',
      hints: ['It was developed by Google.', 'It features sound type-safety and sound null-safety.'],
      multipleChoiceOptions: ['Java', 'Swift', 'Kotlin', 'Dart'],
      correctCount: 8,
      totalCount: 10,
    ),
    Flashcard(
      id: '4',
      question: 'What is the name of this Google DeepMind coding assistant?',
      answer: 'Antigravity',
      hints: ['Starts with A', 'Defies gravity'],
      multipleChoiceOptions: ['Gemini', 'Antigravity', 'Chorus', 'Orion'],
      correctCount: 0,
      totalCount: 0,
    ),
  ];

  late final StreamController<List<Flashcard>> _controller;

  MockFlashcardRepository() {
    _controller = StreamController<List<Flashcard>>.broadcast(
      onListen: () => _controller.add(List.unmodifiable(_cards)),
    );
  }

  @override
  Stream<List<Flashcard>> getFlashcards() {
    return _controller.stream;
  }

  @override
  Future<void> updateFlashcardStats(String cardId, {required bool isCorrect}) async {
    final index = _cards.indexWhere((card) => card.id == cardId);
    if (index != -1) {
      final oldCard = _cards[index];
      _cards[index] = oldCard.copyWith(
        correctCount: oldCard.correctCount + (isCorrect ? 1 : 0),
        totalCount: oldCard.totalCount + 1,
      );
      _controller.add(List.unmodifiable(_cards));
    }
  }

  void dispose() {
    _controller.close();
  }
}
