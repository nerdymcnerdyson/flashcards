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
      title: 'Aquarium Academy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020912),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
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
              Color(0xFF0A1E3F),
              Color(0xFF020912),
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
                    color: const Color(0xFF0C2540),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.2),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.waves_rounded,
                    color: Color(0xFF00E5FF),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Aquarium Academy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Review aquarium animals and facts. Test your knowledge on Monterey Bay Aquarium Aviary birds, identification markings, and behaviors.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
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
                            title: 'Monterey Bay Aviary Shorebirds',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF00B4D8).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Review Animals & Facts',
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
                    color: const Color(0xFF0C2540).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00B4D8).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF00E5FF), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Note: Running in standalone mode using local mock data. Easily swap to FirestoreFlashcardRepository in main.dart.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
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
