import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/flashcard.dart';

class FlashcardCard extends StatefulWidget {
  final Flashcard flashcard;
  final ValueChanged<bool> onAnswered;

  const FlashcardCard({
    super.key,
    required this.flashcard,
    required this.onAnswered,
  });

  @override
  State<FlashcardCard> createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard> with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  bool _isFront = true;
  bool _showMultipleChoice = false;
  String? _selectedOption;
  bool _answeredViaChoice = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset card state if the flashcard changes
    if (widget.flashcard.id != oldWidget.flashcard.id) {
      _resetCard();
    }
  }

  void _resetCard() {
    _flipController.reverse();
    setState(() {
      _isFront = true;
      _showMultipleChoice = false;
      _selectedOption = null;
      _answeredViaChoice = false;
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _handleOptionSelect(String option) {
    if (_answeredViaChoice) return;

    setState(() {
      _selectedOption = option;
      _answeredViaChoice = true;
    });

    final isCorrect = option.toLowerCase() == widget.flashcard.answer.toLowerCase();

    // Call back to parent to log statistics
    widget.onAnswered(isCorrect);

    // Auto flip to back after showing feedback for a brief moment
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _isFront) {
        _toggleFlip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 550,
        ),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * pi;
            final isFrontSide = angle < pi / 2;

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015) // Perspective effect
                ..rotateY(angle),
              alignment: Alignment.center,
              child: isFrontSide
                  ? _buildCardSide(isFront: true)
                  : Transform(
                      transform: Matrix4.identity()..rotateY(pi),
                      alignment: Alignment.center,
                      child: _buildCardSide(isFront: false),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardSide({required bool isFront}) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFF5A4C7A).withOpacity(0.5),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFront
              ? [const Color(0xFF1B1826), const Color(0xFF28203D)]
              : [const Color(0xFF1E1730), const Color(0xFF110E1C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F0C1B).withOpacity(0.6),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.0),
        child: isFront ? _buildFrontContent() : _buildBackContent(),
      ),
    );
  }

  Widget _buildFrontContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image section if present
        if (widget.flashcard.imageUrl != null)
          Expanded(
            flex: _showMultipleChoice ? 2 : 4,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x225A4C7A), width: 1),
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: widget.flashcard.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF221A30),
                  child: const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF9E7EFE),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF221A30),
                  child: const Icon(
                    Icons.broken_image_rounded,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

        // Question details
        Expanded(
          flex: widget.flashcard.imageUrl != null ? (_showMultipleChoice ? 7 : 5) : 9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  widget.flashcard.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),

                // Display Multiple Choice Hint if revealed
                if (_showMultipleChoice && widget.flashcard.multipleChoiceOptions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: widget.flashcard.multipleChoiceOptions.map((option) {
                        final isSelected = _selectedOption == option;
                        final isCorrectOption = option.toLowerCase() == widget.flashcard.answer.toLowerCase();

                        Color buttonColor = const Color(0xFF2F244A);
                        Color borderColor = const Color(0xFF5A4C7A).withOpacity(0.3);
                        Widget? suffixIcon;

                        if (_answeredViaChoice) {
                          if (isCorrectOption) {
                            buttonColor = const Color(0xFF1E4620);
                            borderColor = Colors.greenAccent;
                            suffixIcon = const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20);
                          } else if (isSelected) {
                            buttonColor = const Color(0xFF4C1E1E);
                            borderColor = Colors.redAccent;
                            suffixIcon = const Icon(Icons.cancel, color: Colors.redAccent, size: 20);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: InkWell(
                            onTap: () => _handleOptionSelect(option),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                color: buttonColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (suffixIcon != null) suffixIcon,
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                else if (widget.flashcard.multipleChoiceOptions.isNotEmpty) ...[
                  // Show Hint Button
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showMultipleChoice = true;
                      });
                    },
                    icon: const Icon(Icons.help_outline_rounded, color: Color(0xFFB392FF), size: 18),
                    label: const Text(
                      'Show Multiple Choice Hint',
                      style: TextStyle(
                        color: Color(0xFFB392FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Flip Card prompt
                if (!_answeredViaChoice)
                  TextButton(
                    onPressed: _toggleFlip,
                    child: Text(
                      'Tap to Flip & Reveal Answer',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFFFFD54F),
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ANSWER',
                    style: TextStyle(
                      color: Color(0xFFB392FF),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.flashcard.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Identification Notes Section
                  if (widget.flashcard.notes != null && widget.flashcard.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28203D).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF9E7EFE).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.remove_red_eye_rounded,
                                color: Color(0xFFB392FF),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'WHAT TO LOOK FOR',
                                style: TextStyle(
                                  color: const Color(0xFFB392FF).withOpacity(0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.flashcard.notes!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // Statistics Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1730),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: const Color(0xFF5A4C7A).withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn('Times Asked', '${widget.flashcard.totalCount}'),
                        _buildStatColumn('Accuracy', widget.flashcard.accuracyPercentageString),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manual controls if not answered via Multiple Choice
          if (!_answeredViaChoice) ...[
            const Text(
              'Did you get it right?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.onAnswered(false);
                      _toggleFlip();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Incorrect', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onAnswered(true);
                      _toggleFlip();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Correct', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Finished feedback
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleFlip,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Back to Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A4C7A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
