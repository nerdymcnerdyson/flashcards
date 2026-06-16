class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? imageUrl;
  final List<String> hints;
  final List<String> multipleChoiceOptions;
  final int correctCount;
  final int totalCount;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.imageUrl,
    this.hints = const [],
    this.multipleChoiceOptions = const [],
    this.correctCount = 0,
    this.totalCount = 0,
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
    List<String>? hints,
    List<String>? multipleChoiceOptions,
    int? correctCount,
    int? totalCount,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
      hints: hints ?? this.hints,
      multipleChoiceOptions: multipleChoiceOptions ?? this.multipleChoiceOptions,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'imageUrl': imageUrl,
      'hints': hints,
      'multipleChoiceOptions': multipleChoiceOptions,
      'correctCount': correctCount,
      'totalCount': totalCount,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map, String documentId) {
    return Flashcard(
      id: documentId,
      question: map['question'] as String? ?? '',
      answer: map['answer'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      hints: List<String>.from(map['hints'] ?? const []),
      multipleChoiceOptions: List<String>.from(map['multipleChoiceOptions'] ?? const []),
      correctCount: map['correctCount'] as int? ?? 0,
      totalCount: map['totalCount'] as int? ?? 0,
    );
  }
}
