import 'package:flutter/material.dart';
import 'package:flashcards/flashcards.dart';

void main() {
  runApp(const FlashcardsExampleApp());
}

class FlashcardsExampleApp extends StatelessWidget {
  const FlashcardsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Studio Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0C1B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9E7EFE),
          brightness: Brightness.dark,
        ),
      ),
      home: const FlashcardWelcomeScreen(),
    );
  }
}

class FlashcardWelcomeScreen extends StatefulWidget {
  const FlashcardWelcomeScreen({super.key});

  @override
  State<FlashcardWelcomeScreen> createState() => _FlashcardWelcomeScreenState();
}

class _FlashcardWelcomeScreenState extends State<FlashcardWelcomeScreen> {
  // Define our repository interface, scoped to the current user!
  //
  // To use Firestore, simply instantiate:
  // final FlashcardRepository repository = FirestoreFlashcardRepository(
  //   userId: 'current_user_123', // Scopes all reads/writes to this user doc
  //   firestore: FirebaseFirestore.instance, // Needs Firebase.initializeApp() first
  //   cardsCollectionPath: 'flashcards',
  // );
  final FlashcardRepository repository = MockFlashcardRepository(userId: 'user_1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B1826),
              Color(0xFF0F0C1B),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating icon with subtle neon glow
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF28203D),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9E7EFE).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9E7EFE).withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    color: Color(0xFFB392FF),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Flashcard Studio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A clean, modular flashcard module with support for image questions, multiple-choice hints, and progress tracking statistics.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Primary CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FlashcardDeckScreen(
                            repository: repository,
                            title: 'Vocabulary & Flutter Quiz',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9E7EFE),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF9E7EFE).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Studying',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Clean repository note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1826).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF5A4C7A).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFFB392FF), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Note: Running in standalone mode using in-memory mock repository. Easily swap to FirestoreFlashcardRepository in main.dart.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
