import 'dart:async';
import '../models/flashcard.dart';
import 'flashcard_repository.dart';

class _MockStats {
  final int correctCount;
  final int totalCount;
  final double easinessFactor;
  final int repetitions;
  final int intervalDays;
  final DateTime? nextReviewAt;

  const _MockStats({
    required this.correctCount,
    required this.totalCount,
    this.easinessFactor = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.nextReviewAt,
  });
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

  // Static in-memory database of stats (Map<userId, Map<cardId, _MockStats>>)
  static final Map<String, Map<String, _MockStats>> _statsDb = {
    'user_1': {
      '1': _MockStats(
        correctCount: 4,
        totalCount: 5,
        easinessFactor: 2.6,
        repetitions: 3,
        intervalDays: 6,
        nextReviewAt: DateTime.now().subtract(const Duration(days: 2)), // Overdue card
      ),
      '2': _MockStats(
        correctCount: 2,
        totalCount: 3,
        easinessFactor: 2.3,
        repetitions: 1,
        intervalDays: 1,
        nextReviewAt: DateTime.now().add(const Duration(days: 1)), // Due tomorrow
      ),
      '3': _MockStats(
        correctCount: 8,
        totalCount: 10,
        easinessFactor: 2.8,
        repetitions: 5,
        intervalDays: 18,
        nextReviewAt: DateTime.now().add(const Duration(days: 5)), // Due in 5 days
      ),
      // Card '4' is not in user_1 stats: Treated as a "New" card (overdue)
    },
    'user_2': {
      '1': _MockStats(
        correctCount: 1,
        totalCount: 5,
        easinessFactor: 1.7,
        repetitions: 0,
        intervalDays: 1,
        nextReviewAt: DateTime.now().subtract(const Duration(hours: 12)), // Overdue card
      ),
      '2': _MockStats(
        correctCount: 3,
        totalCount: 3,
        easinessFactor: 2.5,
        repetitions: 3,
        intervalDays: 6,
        nextReviewAt: DateTime.now().add(const Duration(days: 6)),
      ),
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
        easinessFactor: stats?.easinessFactor ?? 2.5,
        repetitions: stats?.repetitions ?? 0,
        intervalDays: stats?.intervalDays ?? 0,
        nextReviewAt: stats?.nextReviewAt,
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
    final oldStats = userStats[cardId] ?? const _MockStats(correctCount: 0, totalCount: 0);

    double newEF = oldStats.easinessFactor;
    int newRepetitions = oldStats.repetitions;
    int newInterval = oldStats.intervalDays;

    if (isCorrect) {
      if (newRepetitions == 0) {
        newInterval = 1;
      } else if (newRepetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (newInterval * newEF).round();
      }
      newRepetitions += 1;
      newEF = double.parse((newEF + 0.1).clamp(1.3, 3.0).toStringAsFixed(1));
    } else {
      newRepetitions = 0;
      newInterval = 1;
      newEF = double.parse((newEF - 0.2).clamp(1.3, 3.0).toStringAsFixed(1));
    }

    final newReviewDate = DateTime.now().add(Duration(days: newInterval));

    userStats[cardId] = _MockStats(
      correctCount: oldStats.correctCount + (isCorrect ? 1 : 0),
      totalCount: oldStats.totalCount + 1,
      easinessFactor: newEF,
      repetitions: newRepetitions,
      intervalDays: newInterval,
      nextReviewAt: newReviewDate,
    );

    _emitMergedCards();
  }

  void dispose() {
    _controller.close();
  }
}
