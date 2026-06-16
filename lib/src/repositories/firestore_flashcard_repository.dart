import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/flashcard.dart';
import 'flashcard_repository.dart';

class FirestoreFlashcardRepository implements FlashcardRepository {
  final FirebaseFirestore _firestore;
  final String collectionPath;

  FirestoreFlashcardRepository({
    FirebaseFirestore? firestore,
    this.collectionPath = 'flashcards',
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Flashcard>> getFlashcards() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Flashcard.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> updateFlashcardStats(String cardId, {required bool isCorrect}) {
    final docRef = _firestore.collection(collectionPath).doc(cardId);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Flashcard with ID $cardId does not exist in Firestore.");
      }

      final data = snapshot.data() ?? {};
      final currentCorrect = data['correctCount'] as int? ?? 0;
      final currentTotal = data['totalCount'] as int? ?? 0;

      transaction.update(docRef, {
        'correctCount': currentCorrect + (isCorrect ? 1 : 0),
        'totalCount': currentTotal + 1,
      });
    });
  }
}
