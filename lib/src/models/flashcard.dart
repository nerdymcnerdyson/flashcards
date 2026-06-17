import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? imageUrl;
  final String? notes;
  final List<String> hints;
  final List<String> multipleChoiceOptions;
  final int correctCount;
  final int totalCount;

  // Spaced Repetition (SM-2) variables
  final double easinessFactor;
  final int repetitions;
  final int intervalDays;
  final DateTime? nextReviewAt;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.imageUrl,
    this.notes,
    this.hints = const [],
    this.multipleChoiceOptions = const [],
    this.correctCount = 0,
    this.totalCount = 0,
    this.easinessFactor = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.nextReviewAt,
  });

  /// Calculates the accuracy as a value between 0.0 and 1.0.
  double get accuracy => totalCount == 0 ? 0.0 : correctCount / totalCount;

  /// Helper to display accuracy percentage formatted to one decimal.
  String get accuracyPercentageString =>
      totalCount == 0 ? '0%' : '${(accuracy * 100).toStringAsFixed(1)}%';

  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? imageUrl,
    String? notes,
    List<String>? hints,
    List<String>? multipleChoiceOptions,
    int? correctCount,
    int? totalCount,
    double? easinessFactor,
    int? repetitions,
    int? intervalDays,
    DateTime? nextReviewAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      hints: hints ?? this.hints,
      multipleChoiceOptions: multipleChoiceOptions ?? this.multipleChoiceOptions,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
      'notes': notes,
      'hints': hints,
      'multipleChoiceOptions': multipleChoiceOptions,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'easinessFactor': easinessFactor,
      'repetitions': repetitions,
      'intervalDays': intervalDays,
      'nextReviewAt': nextReviewAt != null ? Timestamp.fromDate(nextReviewAt!) : null,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parseNextReviewAt(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return Flashcard(
      id: documentId,
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      notes: map['notes'] as String?,
      hints: List<String>.from(map['hints'] ?? const []),
      multipleChoiceOptions: List<String>.from(map['multipleChoiceOptions'] ?? const []),
      correctCount: map['correctCount'] as int? ?? 0,
      totalCount: map['totalCount'] as int? ?? 0,
      easinessFactor: (map['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      repetitions: map['repetitions'] as int? ?? 0,
      intervalDays: map['intervalDays'] as int? ?? 0,
      nextReviewAt: parseNextReviewAt(map['nextReviewAt']),
    );
  }
}
