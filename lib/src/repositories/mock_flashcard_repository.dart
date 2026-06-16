import 'dart:async';
import '../models/flashcard.dart';
import 'flashcard_repository.dart';

class _MockStats {
  final int correctCount;
  final int totalCount;
  const _MockStats(this.correctCount, this.totalCount);
}

class MockFlashcardRepository implements FlashcardRepository {
  final String userId;

  // Static flashcards without statistics
  final List<Flashcard> _baseCards = const [
    Flashcard(
      id: '1',
      question: 'What is the capital of Japan?',
      answer: 'Tokyo',
      imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deceeaf7?w=500&auto=format&fit=crop&q=60',
      hints: ['It starts with T', "It's the most populous metropolitan area in the world."],
      multipleChoiceOptions: ['Kyoto', 'Osaka', 'Tokyo', 'Hiroshima'],
    ),
    Flashcard(
      id: '2',
      question: 'Which Flutter widget allows you to perform 3D rotations or perspective shifts on its child?',
      answer: 'Transform',
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=60',
      hints: ['It uses Matrix4 for coordinates transformation.', 'You can combine it with AnimatedBuilder.'],
      multipleChoiceOptions: ['Rotate', 'Transform', 'Skew', 'MatrixWidget'],
    ),
    Flashcard(
      id: '3',
      question: 'What programming language is Flutter written in and compiles to?',
      answer: 'Dart',
      imageUrl: 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=500&auto=format&fit=crop&q=60',
      hints: ['It was developed by Google.', 'It features sound type-safety and sound null-safety.'],
      multipleChoiceOptions: ['Java', 'Swift', 'Kotlin', 'Dart'],
    ),
    Flashcard(
      id: '4',
      question: 'What is the name of this Google DeepMind coding assistant?',
      answer: 'Antigravity',
      hints: ['Starts with A', 'Defies gravity'],
      multipleChoiceOptions: ['Gemini', 'Antigravity', 'Chorus', 'Orion'],
    ),
  ];

  // In-memory stats database: Map<userId, Map<cardId, _MockStats>>
  static final Map<String, Map<String, _MockStats>> _statsDb = {
    'user_1': {
      '1': const _MockStats(4, 5),
      '2': const _MockStats(2, 3),
      '3': const _MockStats(8, 10),
    },
    'user_2': {
      '1': const _MockStats(1, 5),
      '2': const _MockStats(3, 3),
    }
  };

  late final StreamController<List<Flashcard>> _controller;

  MockFlashcardRepository({this.userId = 'mock_user'}) {
    _controller = StreamController<List<Flashcard>>.broadcast(
      onListen: _emitMergedCards,
    );
  }

  List<Flashcard> _getMergedCards() {
    final userStats = _statsDb[userId] ?? {};
    return _baseCards.map((card) {
      final stats = userStats[card.id];
      return card.copyWith(
        correctCount: stats?.correctCount ?? 0,
        totalCount: stats?.totalCount ?? 0,
      );
    }).toList();
  }

  void _emitMergedCards() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_getMergedCards()));
    }
  }

  @override
  Stream<List<Flashcard>> getFlashcards() {
    return _controller.stream;
  }

  @override
  Future<void> updateFlashcardStats(String cardId, {required bool isCorrect}) async {
    final userStats = _statsDb.putIfAbsent(userId, () => {});
    final oldStats = userStats[cardId] ?? const _MockStats(0, 0);

    userStats[cardId] = _MockStats(
      oldStats.correctCount + (isCorrect ? 1 : 0),
      oldStats.totalCount + 1,
    );

    _emitMergedCards();
  }

  void dispose() {
    _controller.close();
  }
}
