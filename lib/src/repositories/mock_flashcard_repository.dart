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
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Red Phalarope',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Phalaropus_fulicarius_98755138_%28cropped%29.jpg',
      hints: [
        'Swims on the water in spinning circles to stir up food.',
        'Yellow bill with a black tip in the breeding season.'
      ],
      multipleChoiceOptions: ['Red Phalarope', 'Red-necked Phalarope', 'Western Sandpiper', 'Red Knot'],
      notes: 'Look for a rich chestnut-red neck and underbody with white cheek patches and a yellow, black-tipped bill. In winter, they turn pale grey and white with a dark eyepatch. Phalaropes are unusual because females are more brightly colored than males and compete for mates.',
    ),
    Flashcard(
      id: '2',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Red-necked Phalarope',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/5c/Red-necked_Phalarope.jpg',
      hints: [
        'Has a very thin, needle-like black bill.',
        'Swims on the water in circles.'
      ],
      multipleChoiceOptions: ['Red-necked Phalarope', 'Red Phalarope', 'Western Sandpiper', 'Black-necked Stilt'],
      notes: 'Smaller than the Red Phalarope, identified by its very thin, needle-like black bill and dark grey plumage with a bright reddish-chestnut patch on the sides and back of the neck. They spin rapidly in circles on the water to create a mini-whirlpool that brings small invertebrates to the surface.',
    ),
    Flashcard(
      id: '3',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Snowy Plover',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/0a/Snowy_Plover_Morro_Strand.jpg',
      hints: [
        'Very small, sandy-colored plover.',
        'Has dark grey/blackish legs.'
      ],
      multipleChoiceOptions: ['Snowy Plover', 'Killdeer', 'Black-bellied Plover', 'Western Sandpiper'],
      notes: 'A small, pale shorebird with a thin black bill, dark grey legs, and a dark patch behind the eye and on the forehead. They have partial collars (dark smudges on the sides of the breast). They blend in perfectly with dry sand and nest on open sandy beaches, making them vulnerable to disturbance.',
    ),
    Flashcard(
      id: '4',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Black-bellied Plover',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/16/Breeding_plumage_Black-bellied_plover_%28Pluvialis_squatarola%29_Great_Bay_Wildlife_Management_Area%2C_New_Jersey%2C_USA.png',
      hints: [
        'Large plover with a thick black bill.',
        'Look for a solid black face, chest, and belly in summer breeding plumage.'
      ],
      multipleChoiceOptions: ['Black-bellied Plover', 'Snowy Plover', 'Killdeer', 'Marbled Godwit'],
      notes: 'A large plover with a thick black bill. In breeding plumage, it has a striking jet-black face, neck, breast, and belly bordered by a clean white stripe, and a spangled black-and-white back. In winter, they are plain grey-brown but can be identified in flight by their black armpits (axillaries).',
    ),
    Flashcard(
      id: '5',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Black Oystercatcher',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/7/72/Black_Oystercatcher_HMB_RWD4.jpg',
      hints: [
        'Completely black plumage.',
        'Bright orange-red chisel-like bill and bright yellow eyes.'
      ],
      multipleChoiceOptions: ['Black Oystercatcher', 'Black-necked Stilt', 'American Avocet', 'Killdeer'],
      notes: 'Easily recognized by its entirely soot-black body, pale pink legs, yellow eyes with red eye-rings, and a long, bright red-orange chisel-like bill. They live exclusively on rocky shorelines, using their specialized bills to pry limpets and mussels off the rocks.',
    ),
    Flashcard(
      id: '6',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Killdeer',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/cb/Killdeer_Heislerville.png',
      hints: [
        'Two black breast bands (double collar).',
        'Loud, piercing call that sounds like its name.'
      ],
      multipleChoiceOptions: ['Killdeer', 'Snowy Plover', 'Black-bellied Plover', 'Black Oystercatcher'],
      notes: 'A medium-sized plover with a brown back, white belly, and two bold black bands across the chest. They have a long tail with orange-brown rump feathers visible in flight. Famous for their dramatic \'broken-wing display\' used to lure predators away from their ground nests.',
    ),
    Flashcard(
      id: '7',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Red Knot',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/03/Rufa_red_knot_%28Calidris_canutus_rufa%29_in_Delaware_Bay%2C_New_Jersey.jpg',
      hints: [
        'Medium-sized stocky sandpiper.',
        'Robin-red breast and face in breeding plumage.'
      ],
      multipleChoiceOptions: ['Red Knot', 'Red Phalarope', 'Western Sandpiper', 'Marbled Godwit'],
      notes: 'A stocky, medium-sized sandpiper with a straight black bill. In breeding plumage, it has a beautiful salmon-red face, neck, and breast. Red Knots are famous for their extraordinary long-distance migrations, flying up to 9,000 miles twice a year from Tierra del Fuego to the Arctic.',
    ),
    Flashcard(
      id: '8',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Marbled Godwit',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/9/9b/MarbledGodwit.jpg',
      hints: [
        'Very large shorebird.',
        'Long, slightly upturned bill with a pink base and black tip.'
      ],
      multipleChoiceOptions: ['Marbled Godwit', 'American Avocet', 'Black-necked Stilt', 'Red Knot'],
      notes: 'A very large, cinnamon-brown shorebird with a long, slightly upturned bi-colored bill (pink at the base, black at the tip). They use their long bills to probe deep into wet sand and mud for worms and crabs.',
    ),
    Flashcard(
      id: '9',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Black-necked Stilt',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/37/Black-necked_Stilt_%28Himantopus_mexicanus%29%2C_Corte_Madera.jpg',
      hints: [
        'Extremely long, thin pinkish-red legs.',
        'Jet-black back and neck contrasted with a white belly.'
      ],
      multipleChoiceOptions: ['Black-necked Stilt', 'American Avocet', 'Black Oystercatcher', 'Red-necked Phalarope'],
      notes: 'Has the second-longest legs relative to body length of any bird (second only to flamingos). Identified by its needle-like black bill, black wings and back, white underparts, and bright pink-red legs. Often seen wading in shallow water.',
    ),
    Flashcard(
      id: '10',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'American Avocet',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/d/de/American_Avocet1.jpg',
      hints: [
        'Long, thin, upturned bill.',
        'Peach-colored head and neck in breeding season.'
      ],
      multipleChoiceOptions: ['American Avocet', 'Black-necked Stilt', 'Marbled Godwit', 'Red Knot'],
      notes: 'An elegant wader with a long, thin, upward-curved bill. During the breeding season, its head and neck turn a warm, rusty peach color. In winter, they are grey and white. They feed by sweeping their open bill from side to side through shallow water.',
    ),
    Flashcard(
      id: '11',
      question: 'Identify this MBAQ Aviary bird species.',
      answer: 'Western Sandpiper',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/51/Western_Sandpiper.jpg',
      hints: [
        'Small shorebird (\'peep\') with black legs.',
        'Thin black bill that is slightly drooped at the tip.'
      ],
      multipleChoiceOptions: ['Western Sandpiper', 'Snowy Plover', 'Red Knot', 'Red-necked Phalarope'],
      notes: 'A small, abundant shorebird with black legs and a black bill that droops slightly at the tip. Breeding adults have rufous (reddish-brown) patches on the crown, cheeks, and back, and fine arrow-shaped spots on the breast. Often seen in massive flocks along sandy beaches.',
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
