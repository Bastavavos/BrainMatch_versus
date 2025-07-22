import 'dart:async';
import 'dart:convert';
import 'package:brain_match/ui/screens/quiz/quiz_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../resources/socket_client.dart';
import '../../layout/special_layout.dart';

class QuizPlayPage extends StatefulWidget {
  final String categoryId;
  final String mode;
  final Map<String, dynamic>? versusData;
  final String currentUser;
  final String token;

  const QuizPlayPage({
    super.key,
    required this.categoryId,
    required this.mode,
    this.versusData,
    required this.currentUser,
    required this.token,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  List<dynamic> questions = [];
  // List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  int? selectedIndex;
  bool hasAnswered = false;
  int correctAnswers = 0;
  bool opponentHasAnswered = false;

  Timer? countdownTimer;
  double timeLeft = 10.0;

  @override
  void initState() {
    super.initState();

    if (widget.mode == 'Versus' && widget.versusData != null) {

      setState(() {
        questions = List<Map<String, dynamic>>.from(widget.versusData!['quiz']['subTheme']['questions']);
        isLoading = false;
      });

      startTimer();

      // Connexion socket uniquement pour recevoir les résultats et autres events
      SocketClient().connect(
        token: widget.token,
        categoryId: widget.categoryId,
        currentUser: widget.currentUser,
        isHost: widget.versusData!['isHost'],
        // isHost: widget.versusData?['isHost'] == true, //NEW with default value
        // isHost: widget.versusData?['isHost'] is bool ? widget.versusData!['isHost'] : false,  // defensif
        onStartGame: (_) {},
        onQuestionResult: handleQuestionResult,
        onError: (message) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur socket : $message')),
            );
          }
        },
      );
    } else {
      fetchQuestionData().then((_) {
        if (questions.isNotEmpty) startTimer();
      });
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchQuestionData() async {
    final baseUrl = dotenv.env['API_KEY'];
    final url = '$baseUrl/quiz/question/${widget.categoryId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data['subTheme']['questions']);
          // questions = [data['question']];
          isLoading = false;
        });
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement : $e')),
        );
      }
    }
  }

  void startTimer() {
    countdownTimer?.cancel();
    setState(() {
      timeLeft = 10;
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timeLeft <= 0) {
        timer.cancel();
        if (!hasAnswered) {
          setState(() {
            hasAnswered = true;
          });
          Future.delayed(const Duration(seconds: 1), () {
            goToNextQuestion();
          });
        }
      } else {
        setState(() {
          timeLeft -= 0.1;
        });
      }
    });
  }

  void goToNextQuestion() {
    countdownTimer?.cancel();
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedIndex = null;
        hasAnswered = false;
        timeLeft = 10;
      });
      startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            totalQuestions: questions.length,
            correctAnswers: correctAnswers,
            mode: widget.mode,
          ),
        ),
      );
    }
  }

  void handleQuestionResult(data) {
    if (!mounted) return; // <- Très important
    setState(() {
      timeLeft = 0;
    });

    final myScoreObj = (data['playersScores'] as List).firstWhere(
          (player) => player['username'] == widget.currentUser,
      orElse: () => null,
    );

    if (myScoreObj != null) {
      setState(() {
        hasAnswered = true;
        correctAnswers = myScoreObj['score'];
      });
    } else {
      opponentHasAnswered = true;
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (data['nextQuestionIndex'] < questions.length) {
        setState(() {
          currentQuestionIndex = data['nextQuestionIndex'];
          hasAnswered = false;
          selectedIndex = null;
          startTimer();
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultPage(
              totalQuestions: questions.length,
              correctAnswers: correctAnswers,
              mode: widget.mode,
            ),
          ),
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final bool isSolo = widget.mode == 'Solo';
    final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;

    return SpeLayout(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : questions.isEmpty
          ? const Center(child: Text("Aucune question disponible"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                questions[currentQuestionIndex]['image'],
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timeLeft / 10,
                backgroundColor: Colors.grey[300],
                color: primaryColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              questions[currentQuestionIndex]['question'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasAnswered && opponentHasAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  "L'adversaire a répondu",
                  style: TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            ...List.generate(
              questions[currentQuestionIndex]['options'].length,
                  (index) {
                final option = questions[currentQuestionIndex]['options'][index];
                final correctAnswer = questions[currentQuestionIndex]['answer'];
                final isCorrect = option == correctAnswer;
                final isSelected = index == selectedIndex;

                Color borderColor = Colors.grey.shade300;
                Icon? trailingIcon;

                if (hasAnswered) {
                  if (isSelected) {
                    borderColor = isCorrect ? Colors.green : Colors.red;
                    trailingIcon = Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    );
                  } else if (isCorrect) {
                    borderColor = Colors.green;
                    trailingIcon = const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    );
                  }
                }
                return GestureDetector(
                  onTap: () {
                    if (!hasAnswered) {
                      setState(() {
                        selectedIndex = index;
                        hasAnswered = true;
                        if (isCorrect) correctAnswers++;
                      });
                      countdownTimer?.cancel();

                      if (widget.mode == 'Versus' && widget.versusData != null) {
                        SocketClient().sendAnswer(
                          roomId: widget.versusData!['roomId'],
                          questionIndex: currentQuestionIndex,
                          answer: option,
                          username: widget.versusData!['players'][0]['username'], // ou autre si joueur 2
                        );
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            if (hasAnswered && widget.mode == 'Solo')
              ElevatedButton(
                onPressed: goToNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



