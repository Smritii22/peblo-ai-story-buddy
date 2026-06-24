import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

// ─── DATA MODEL ───────────────────────────────────────────────
// This is like a blueprint for our quiz question
class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  // This reads the JSON data (like reading from a backend server)
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}

// ─── APP STATE (BRAIN OF THE APP) ─────────────────────────────
class StoryProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  // All the possible states of our app
  String _audioState = 'idle'; // idle, loading, playing, done, error
  String _quizState = 'hidden'; // hidden, visible
  String? _selectedAnswer;
  bool _isCorrect = false;

  // Getters (ways to read the state)
  String get audioState => _audioState;
  String get quizState => _quizState;
  String? get selectedAnswer => _selectedAnswer;
  bool get isCorrect => _isCorrect;

  // The story text
  final String storyText =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  // The quiz data - loaded from JSON (like a backend!)
  final QuizQuestion quiz = QuizQuestion.fromJson({
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue"
  });

  StoryProvider() {
    _setupTts();
  }

  void _setupTts() async {
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);

    // When audio finishes → show the quiz!
    _tts.setCompletionHandler(() {
      _audioState = 'done';
      _quizState = 'visible';
      notifyListeners();
    });

    // If TTS fails
    _tts.setErrorHandler((error) {
      _audioState = 'error';
      notifyListeners();
    });
  }

  Future<void> readStory() async {
    try {
      _audioState = 'loading';
      _quizState = 'hidden';
      _selectedAnswer = null;
      _isCorrect = false;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));
      _audioState = 'playing';
      notifyListeners();

      await _tts.speak(storyText);
    } catch (e) {
      _audioState = 'error';
      notifyListeners();
    }
  }

  void selectAnswer(String answer, VoidCallback onWrong,
      VoidCallback onCorrect) {
    _selectedAnswer = answer;
    if (answer == quiz.answer) {
      _isCorrect = true;
      _quizState = 'success';
      HapticFeedback.heavyImpact();
      onCorrect();
    } else {
      _isCorrect = false;
      HapticFeedback.vibrate();
      onWrong();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

// ─── MAIN ENTRY POINT ─────────────────────────────────────────
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: const PebloApp(),
    ),
  );
}

class PebloApp extends StatelessWidget {
  const PebloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: const StoryScreen(),
    );
  }
}

// ─── MAIN SCREEN ──────────────────────────────────────────────
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti setup
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Shake animation setup
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onWrongAnswer() {
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  void _onCorrectAnswer() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFFFF6584), Color(0xFFFFD93D)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildBuddyCharacter(),
                    const SizedBox(height: 20),
                    _buildStoryCard(),
                    const SizedBox(height: 20),
                    _buildAudioButton(),
                    const SizedBox(height: 20),
                    _buildQuizSection(),
                  ],
                ),
              ),
              // Confetti on top!
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  colors: const [
                    Colors.red, Colors.blue, Colors.yellow,
                    Colors.green, Colors.purple
                  ],
                  numberOfParticles: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      '📚 Peblo Story Buddy',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
      ),
    );
  }

  Widget _buildBuddyCharacter() {
    final provider = context.watch<StoryProvider>();
    String emoji = '🤖';
    if (provider.audioState == 'playing') emoji = '🎙️';
    if (provider.quizState == 'success') emoji = '🥳';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        emoji,
        key: ValueKey(emoji),
        style: const TextStyle(fontSize: 80),
      ),
    );
  }

  Widget _buildStoryCard() {
    final provider = context.watch<StoryProvider>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Text(
        provider.storyText,
        style: const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Color(0xFF333333),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAudioButton() {
    final provider = context.watch<StoryProvider>();

    if (provider.audioState == 'loading') {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (provider.audioState == 'playing') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volume_up, color: Colors.white),
            SizedBox(width: 8),
            Text('Reading story...', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      );
    }

    if (provider.audioState == 'error') {
      return Column(
        children: [
          const Text('😕 Oops! Could not read the story.',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.readStory(),
            child: const Text('Try Again'),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: () => provider.readStory(),
      icon: const Icon(Icons.play_circle_fill, size: 28),
      label: Text(
        provider.audioState == 'done' ? '🔁 Read Again' : '🎧 Read Me a Story',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6C63FF),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
      ),
    );
  }

  Widget _buildQuizSection() {
    final provider = context.watch<StoryProvider>();

    if (provider.quizState == 'hidden') return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: provider.quizState != 'hidden' ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          // Question
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              provider.quiz.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // Answer options - built from JSON dynamically!
          ...provider.quiz.options.map((option) {
            return _buildOptionButton(option, provider);
          }),

          // Success message
          if (provider.quizState == 'success') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '🎉 Amazing! Blue is correct!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, StoryProvider provider) {
    final isSelected = provider.selectedAnswer == option;
    final isSuccess = provider.quizState == 'success';
    final isCorrectOption = option == provider.quiz.answer;

    Color btnColor = Colors.white;
    if (isSelected && !provider.isCorrect) btnColor = Colors.red.shade100;
    if (isSuccess && isCorrectOption) btnColor = Colors.green.shade100;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        double offset = (isSelected && !provider.isCorrect)
            ? _shakeAnimation.value * ((_shakeController.value * 10).round().isEven ? 1 : -1)
            : 0;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSuccess
              ? null
              : () => provider.selectAnswer(
                    option,
                    _onWrongAnswer,
                    _onCorrectAnswer,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: const Color(0xFF333333),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 3,
          ),
          child: Text(
            option,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}