import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../repositories/flashcard_repository.dart';
import '../widgets/flashcard_card.dart';

class FlashcardDeckScreen extends StatefulWidget {
  final FlashcardRepository repository;
  final String title;

  const FlashcardDeckScreen({
    super.key,
    required this.repository,
    this.title = 'Flashcard Deck',
  });

  @override
  State<FlashcardDeckScreen> createState() => _FlashcardDeckScreenState();
}

class _FlashcardDeckScreenState extends State<FlashcardDeckScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextCard() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevCard() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  double _calculateOverallAccuracy(List<Flashcard> cards) {
    int total = 0;
    int correct = 0;
    for (var card in cards) {
      total += card.totalCount;
      correct += card.correctCount;
    }
    return total == 0 ? 0.0 : correct / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B1826),
        elevation: 0,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: StreamBuilder<List<Flashcard>>(
        stream: widget.repository.getFlashcards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9E7EFE),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading flashcards: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            );
          }

          final rawCards = snapshot.data ?? [];
          final cards = List<Flashcard>.from(rawCards)..sort((a, b) {
            final now = DateTime.now();
            final aDue = a.nextReviewAt == null || a.nextReviewAt!.isBefore(now);
            final bDue = b.nextReviewAt == null || b.nextReviewAt!.isBefore(now);

            if (aDue && !bDue) return -1;
            if (!aDue && bDue) return 1;

            if (a.nextReviewAt == null && b.nextReviewAt != null) return -1;
            if (a.nextReviewAt != null && b.nextReviewAt == null) return 1;
            if (a.nextReviewAt == null && b.nextReviewAt == null) return 0;
            return a.nextReviewAt!.compareTo(b.nextReviewAt!);
          });

          if (cards.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: Color(0xFF5A4C7A)),
                  SizedBox(height: 16),
                  Text(
                    'No flashcards found.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Bound current index just in case data size changes
          if (_currentIndex >= cards.length) {
            _currentIndex = cards.length - 1;
          }

          final overallAccuracy = _calculateOverallAccuracy(cards);
          final progress = cards.isEmpty ? 0.0 : (_currentIndex + 1) / cards.length;

          return SafeArea(
            child: Column(
              children: [
                // Top Progress Bar & Session Metrics
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Card ${_currentIndex + 1} of ${cards.length}',
                            style: const TextStyle(
                              color: Color(0xFFB392FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Deck Accuracy: ${(overallAccuracy * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;
                            final barWidth = totalWidth * progress;

                            return Stack(
                              children: [
                                Container(
                                  height: 6,
                                  color: const Color(0xFF221A30),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 6,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF9E7EFE), Color(0xFFD06BFA)],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Flashcard Deck
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: cards.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return FlashcardCard(
                        // Use a key to reset states of inner cards when index/id changes
                        key: ValueKey(card.id),
                        flashcard: card,
                        onAnswered: (isCorrect) async {
                          try {
                            await widget.repository.updateFlashcardStats(
                              card.id,
                              isCorrect: isCorrect,
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update stats: $e'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),

                // Navigation Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      IconButton.filledTonal(
                        onPressed: _currentIndex > 0 ? _prevCard : null,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1B1826),
                          disabledBackgroundColor: const Color(0xFF1B1826).withOpacity(0.3),
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),

                      // Quick Hint or Info Text
                      Text(
                        'Swipe left/right to browse',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),

                      // Next button
                      IconButton.filledTonal(
                        onPressed: _currentIndex < cards.length - 1 ? _nextCard : null,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1B1826),
                          disabledBackgroundColor: const Color(0xFF1B1826).withOpacity(0.3),
                          padding: const EdgeInsets.all(16),
                        ),
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
