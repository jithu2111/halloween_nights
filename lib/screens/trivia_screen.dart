import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'dart:math';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen>
    with TickerProviderStateMixin {
  List<TriviaQuestion> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool hasAnswered = false;
  bool gameStarted = false;
  bool gameFinished = false;
  int? selectedAnswerIndex;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    _shuffleQuestions();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeQuestions() {
    questions = [
      TriviaQuestion(
        question: "What vegetable was originally used to make jack-o'-lanterns?",
        options: ["Pumpkins", "Turnips", "Carrots", "Potatoes"],
        correctAnswer: 1,
        explanation: "Originally, jack-o'-lanterns were carved from turnips and potatoes in Ireland and Scotland!",
      ),
      TriviaQuestion(
        question: "Which country is believed to be the birthplace of Halloween?",
        options: ["America", "Ireland", "Scotland", "England"],
        correctAnswer: 1,
        explanation: "Halloween originated from the ancient Celtic festival of Samhain in Ireland.",
      ),
      TriviaQuestion(
        question: "What does the word 'Halloween' mean?",
        options: ["Ghost Night", "All Hallows' Eve", "Scary Time", "Dark Night"],
        correctAnswer: 1,
        explanation: "Halloween is short for 'All Hallows' Eve', the night before All Saints' Day.",
      ),
      TriviaQuestion(
        question: "Which phobia is the fear of Halloween?",
        options: ["Arachnophobia", "Nyctophobia", "Samhainophobia", "Coulrophobia"],
        correctAnswer: 2,
        explanation: "Samhainophobia is the fear of Halloween, named after the Celtic festival Samhain.",
      ),
      TriviaQuestion(
        question: "What was the original purpose of wearing costumes on Halloween?",
        options: ["To look scary", "To hide from ghosts", "To celebrate harvest", "To honor the dead"],
        correctAnswer: 1,
        explanation: "People wore costumes to disguise themselves from ghosts and spirits they believed roamed the earth.",
      ),
      TriviaQuestion(
        question: "Which candy was originally called 'Chicken Feed'?",
        options: ["Candy Corn", "Gummy Bears", "Chocolate Bars", "Lollipops"],
        correctAnswer: 0,
        explanation: "Candy corn was originally marketed as 'Chicken Feed' in the 1880s.",
      ),
      TriviaQuestion(
        question: "What do you call a group of witches?",
        options: ["A cluster", "A coven", "A gathering", "A circle"],
        correctAnswer: 1,
        explanation: "A group of witches is called a coven, traditionally consisting of 13 members.",
      ),
      TriviaQuestion(
        question: "In which Shakespeare play do three witches appear?",
        options: ["Hamlet", "Romeo and Juliet", "Macbeth", "Othello"],
        correctAnswer: 2,
        explanation: "The three witches appear in Macbeth, predicting his rise to power.",
      ),
      TriviaQuestion(
        question: "What is the most popular Halloween candy in America?",
        options: ["Snickers", "Candy Corn", "Chocolate Bars", "Skittles"],
        correctAnswer: 1,
        explanation: "Candy corn remains the most popular Halloween candy, with over 35 million pounds sold annually.",
      ),
      TriviaQuestion(
        question: "Which horror movie character wears a hockey mask?",
        options: ["Michael Myers", "Freddy Krueger", "Jason Voorhees", "Chucky"],
        correctAnswer: 2,
        explanation: "Jason Voorhees from the Friday the 13th series is famous for his hockey mask.",
      ),
    ];
  }

  void _shuffleQuestions() {
    questions.shuffle(Random());
    questions = questions.take(5).toList();
  }

  void startGame() {
    setState(() {
      gameStarted = true;
      gameFinished = false;
      currentQuestionIndex = 0;
      score = 0;
      hasAnswered = false;
      selectedAnswerIndex = null;
    });
    _slideController.forward();
  }

  void selectAnswer(int answerIndex) {
    if (hasAnswered) return;

    setState(() {
      selectedAnswerIndex = answerIndex;
      hasAnswered = true;
      if (answerIndex == questions[currentQuestionIndex].correctAnswer) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        hasAnswered = false;
        selectedAnswerIndex = null;
      });
      _slideController.reset();
      _slideController.forward();
    } else {
      setState(() {
        gameFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Halloween Trivia',
          style: AppFonts.creepster(fontSize: 24),
        ),
        backgroundColor: const Color(0xFF228B22),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (!gameStarted) {
      return _buildStartScreen();
    } else if (gameFinished) {
      return _buildResultScreen();
    } else {
      return _buildQuestionScreen();
    }
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Text(
                  '🧙‍♀️',
                  style: const TextStyle(fontSize: 100),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            'Halloween Trivia',
            style: AppFonts.creepster(
              fontSize: 36,
              color: const Color(0xFF228B22),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Test your spooky knowledge!\n\n'
            '🎃 5 Random Questions\n'
            '👻 Multiple Choice\n'
            '🧙‍♀️ Learn Fun Facts\n'
            '⭐ Beat Your High Score',
            style: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF228B22),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'Start Quiz',
              style: AppFonts.creepster(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = questions[currentQuestionIndex];
    
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(),
          const SizedBox(height: 20),
          _buildQuestionCard(question),
          const SizedBox(height: 30),
          Expanded(
            child: _buildAnswerOptions(question),
          ),
          if (hasAnswered) _buildExplanation(question),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: AppFonts.creepster(
                fontSize: 16,
                color: const Color(0xFF228B22),
              ),
            ),
            Text(
              'Score: $score',
              style: AppFonts.creepster(
                fontSize: 16,
                color: const Color(0xFF228B22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / questions.length,
          backgroundColor: Colors.white30,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF228B22)),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(TriviaQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF228B22),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF228B22).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        question.question,
        style: AppFonts.roboto(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAnswerOptions(TriviaQuestion question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildAnswerOption(question, index),
        );
      },
    );
  }

  Widget _buildAnswerOption(TriviaQuestion question, int index) {
    bool isSelected = selectedAnswerIndex == index;
    bool isCorrect = index == question.correctAnswer;
    bool showResult = hasAnswered;

    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.white;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF228B22).withOpacity(0.3);
        borderColor = const Color(0xFF228B22);
      } else if (isSelected) {
        backgroundColor = const Color(0xFF8B0000).withOpacity(0.3);
        borderColor = const Color(0xFF8B0000);
      } else {
        backgroundColor = Colors.white10;
        borderColor = Colors.white30;
        textColor = Colors.white70;
      }
    } else {
      backgroundColor = Colors.white10;
      borderColor = Colors.white30;
    }

    return GestureDetector(
      onTap: () => selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: borderColor,
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: AppFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                question.options[index],
                style: AppFonts.roboto(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
            if (showResult && isCorrect)
              const Icon(Icons.check_circle, color: Color(0xFF228B22)),
            if (showResult && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Color(0xFF8B0000)),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(TriviaQuestion question) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF4B0082).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4B0082),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: Color(0xFFFFD700),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Did you know?',
                style: AppFonts.creepster(
                  fontSize: 16,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: AppFonts.roboto(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    double percentage = (score / questions.length) * 100;
    String grade = _getGrade(percentage);
    String emoji = _getGradeEmoji(percentage);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 120),
          ),
          const SizedBox(height: 20),
          Text(
            'Quiz Complete!',
            style: AppFonts.creepster(
              fontSize: 32,
              color: const Color(0xFF228B22),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E).withOpacity(0.8),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF228B22),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Final Score',
                  style: AppFonts.creepster(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$score / ${questions.length}',
                  style: AppFonts.creepster(
                    fontSize: 36,
                    color: const Color(0xFF228B22),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${percentage.toInt()}% - $grade',
                  style: AppFonts.roboto(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _shuffleQuestions();
                  startGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF228B22),
                ),
                child: Text(
                  'Play Again',
                  style: AppFonts.creepster(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                ),
                child: Text(
                  'Back Home',
                  style: AppFonts.creepster(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'Spooky Master!';
    if (percentage >= 80) return 'Ghost Expert';
    if (percentage >= 70) return 'Witch Apprentice';
    if (percentage >= 60) return 'Pumpkin Novice';
    return 'Mortal Human';
  }

  String _getGradeEmoji(double percentage) {
    if (percentage >= 90) return '🏆';
    if (percentage >= 80) return '👻';
    if (percentage >= 70) return '🧙‍♀️';
    if (percentage >= 60) return '🎃';
    return '💀';
  }
}

class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}