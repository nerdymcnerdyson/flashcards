import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/flashcard.dart';
import 'flashcard_repository.dart';

class FirestoreFlashcardRepository implements FlashcardRepository {
  final FirebaseFirestore _firestore;
  final String userId;
  final String cardsCollectionPath;

  FirestoreFlashcardRepository({
    required this.userId,
    FirebaseFirestore? firestore,
    this.cardsCollectionPath = 'flashcards',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Flashcard>> getFlashcards() {
    final cardsSnapshots = _firestore.collection(cardsCollectionPath).snapshots();
    final statsSnapshots = _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcard_stats')
        .snapshots();

    return Rx.combineLatest2<
        QuerySnapshot<Map<String, dynamic>>,
        QuerySnapshot<Map<String, dynamic>>,
        List<Flashcard>>(
      cardsSnapshots,
      statsSnapshots,
      (cardsSnap, statsSnap) {
        final statsMap = {
          for (var doc in statsSnap.docs) doc.id: doc.data()
        };

        return cardsSnap.docs.map((doc) {
          final cardData = doc.data();
          final cardId = doc.id;
          final stats = statsMap[cardId];

          final correctCount = stats?['correctCount'] as int? ?? 0;
          final totalCount = stats?['totalCount'] as int? ?? 0;

          return Flashcard.fromMap({
            ...cardData,
            'correctCount': correctCount,
            'totalCount': totalCount,
          }, cardId);
        }).toList();
      },
    );
  }

  @override
  Future<void> updateFlashcardStats(String cardId, {required bool isCorrect}) {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcard_stats')
        .doc(cardId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int currentCorrect = 0;
      int currentTotal = 0;
      double currentEF = 2.5;
      int currentRepetitions = 0;
      int currentInterval = 0;

      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        currentCorrect = data['correctCount'] as int? ?? 0;
        currentTotal = data['totalCount'] as int? ?? 0;
        currentEF = (data['easinessFactor'] as num?)?.toDouble() ?? 2.5;
        currentRepetitions = data['repetitions'] as int? ?? 0;
        currentInterval = data['intervalDays'] as int? ?? 0;
      }

      double newEF = currentEF;
      int newRepetitions = currentRepetitions;
      int newInterval = currentInterval;

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

      transaction.set(
        docRef,
        {
          'correctCount': currentCorrect + (isCorrect ? 1 : 0),
          'totalCount': currentTotal + 1,
          'easinessFactor': newEF,
          'repetitions': newRepetitions,
          'intervalDays': newInterval,
          'nextReviewAt': Timestamp.fromDate(newReviewDate),
        },
        SetOptions(merge: true),
      );
    });
  }
}
