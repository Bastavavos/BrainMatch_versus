import 'dart:async';
import 'dart:convert';
import 'package:brain_match/ui/screens/quiz/quiz_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../layout/special_layout.dart';

// Événements simulés pour la communication entre joueurs (dans une vraie app, viendrait d'un backend)
enum VersusPlayerAction { answered, timeExpired }

class PlayerAnswerEvent {
  final String playerId;
  final int? selectedOptionIndex; // null si le temps a expiré sans réponse
  final bool isCorrect;
  final VersusPlayerAction action;

  PlayerAnswerEvent({
    required this.playerId,
    this.selectedOptionIndex,
    required this.isCorrect,
    required this.action,
  });
}

class QuizPlayPage extends StatefulWidget {
  final String categoryId;
  final String mode;
  final Map<String, dynamic>? versusData; // Ex: {'localPlayerId': 'player1', 'opponentPlayerId': 'player2', 'quiz': {...}}

  const QuizPlayPage({
    super.key,
    required this.categoryId,
    required this.mode,
    this.versusData,
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;

  // États spécifiques au joueur local
  int? localPlayerSelectedIndex;
  bool localPlayerHasAnsweredThisQuestion = false;
  int localPlayerCorrectAnswers = 0;

  // États pour suivre l'autre joueur en mode Versus
  String? localPlayerId;
  String? opponentPlayerId;
  int? opponentPlayerSelectedIndex;
  bool opponentPlayerHasAnsweredThisQuestion = false;
  int opponentPlayerCorrectAnswers = 0; // Pourrait être utile pour l'affichage final

  bool bothPlayersAnsweredOrTimedOut = false;

  Timer? countdownTimer;
  double timeLeft = 10.0; // Temps par question

  // Simulateur de communication (à remplacer par une vraie solution type WebSockets/Firebase)
  final StreamController<PlayerAnswerEvent> _opponentActionsController = StreamController.broadcast();
  Stream<PlayerAnswerEvent> get opponentActions => _opponentActionsController.stream;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'Versus' && widget.versusData != null) {
      localPlayerId = widget.versusData!['localPlayerId'] ?? 'player1'; // Assurez-vous que ces clés existent
      opponentPlayerId = widget.versusData!['opponentPlayerId'] ?? 'player2';
      questions = List<Map<String, dynamic>>.from(widget.versusData!['quiz']['subTheme']['questions']);
      isLoading = false;
      _listenToOpponentActions(); // Écouter les actions simulées de l'adversaire
      startNewQuestion();
    } else {
      fetchQuestionData().then((_) {
        if (questions.isNotEmpty) {
          startNewQuestion();
        }
      });
    }
  }

  void _listenToOpponentActions() {
    opponentActions.listen((event) {
      if (event.playerId == opponentPlayerId && mounted) {
        setState(() {
          opponentPlayerHasAnsweredThisQuestion = true;
          opponentPlayerSelectedIndex = event.selectedOptionIndex;
          if (event.isCorrect && event.action == VersusPlayerAction.answered) {
            // Vous pourriez vouloir compter les points de l'adversaire si nécessaire pour l'UI
            // opponentPlayerCorrectAnswers++;
          }
          _checkIfProceedToNextQuestion();
        });
      }
    });
  }

  // Méthode pour simuler la réception d'une réponse de l'adversaire
  // Dans une vraie application, cela serait déclenché par votre backend
  void simulateOpponentAnswer(int? optionIndex, bool isCorrect) {
    if (widget.mode == 'Versus') {
      _opponentActionsController.add(PlayerAnswerEvent(
        playerId: opponentPlayerId!,
        selectedOptionIndex: optionIndex,
        isCorrect: isCorrect,
        action: VersusPlayerAction.answered,
      ));
    }
  }

  void simulateOpponentTimeout() {
    if (widget.mode == 'Versus') {
      _opponentActionsController.add(PlayerAnswerEvent(
        playerId: opponentPlayerId!,
        isCorrect: false, // Non applicable ou faux
        action: VersusPlayerAction.timeExpired,
      ));
    }
  }


  @override
  void dispose() {
    countdownTimer?.cancel();
    _opponentActionsController.close();
    super.dispose();
  }

  Future<void> fetchQuestionData() async {
    // ... (votre code fetchQuestionData reste le même)
    final baseUrl = dotenv.env['API_KEY'];
    final url = '$baseUrl/quiz/question/${widget.categoryId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data['subTheme']['questions']);
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

  void startNewQuestion() {
    countdownTimer?.cancel();
    setState(() {
      timeLeft = 10.0;
      localPlayerSelectedIndex = null;
      localPlayerHasAnsweredThisQuestion = false;
      opponentPlayerSelectedIndex = null;
      opponentPlayerHasAnsweredThisQuestion = false;
      bothPlayersAnsweredOrTimedOut = false;
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (timeLeft <= 0) {
        timer.cancel();
        handleQuestionTimeout();
      } else {
        // En mode Versus, si les deux joueurs ont répondu, arrêter le timer plus tôt.
        if (widget.mode == 'Versus' && localPlayerHasAnsweredThisQuestion && opponentPlayerHasAnsweredThisQuestion) {
          timer.cancel();
          // _checkIfProceedToNextQuestion() sera appelé par la dernière action de réponse.
        }
        setState(() {
          timeLeft -= 0.1;
        });
      }
    });
  }

  void handleQuestionTimeout() {
    if (!mounted) return;
    setState(() {
      bothPlayersAnsweredOrTimedOut = true; // Marquer la fin de la question
      // Si le joueur local n'a pas répondu, marquer comme tel
      if (!localPlayerHasAnsweredThisQuestion) {
        localPlayerHasAnsweredThisQuestion = true; // Pour l'affichage, mais sans sélection
        // En mode Versus, informer l'autre joueur (ou le serveur) du timeout du joueur local
        // sendMyTimeoutToServer();
      }
      // Si l'adversaire n'a pas répondu (selon notre état simulé)
      if (widget.mode == 'Versus' && !opponentPlayerHasAnsweredThisQuestion) {
        opponentPlayerHasAnsweredThisQuestion = true; // Pour l'affichage
        // simulateOpponentTimeout(); // Ceci serait une info reçue normalement
      }
    });

    // Attendre un peu pour montrer les résultats avant de passer à la question suivante
    Future.delayed(const Duration(seconds: 2), () { // Augmentez la durée si nécessaire
      goToNextQuestion();
    });
  }

  void onLocalPlayerAnswer(int index) {
    if (localPlayerHasAnsweredThisQuestion || bothPlayersAnsweredOrTimedOut) return;

    final option = questions[currentQuestionIndex]['options'][index];
    final correctAnswer = questions[currentQuestionIndex]['answer'];
    final isCorrect = option == correctAnswer;

    setState(() {
      localPlayerSelectedIndex = index;
      localPlayerHasAnsweredThisQuestion = true;
      if (isCorrect) {
        localPlayerCorrectAnswers++;
      }
    });

    if (widget.mode == 'Versus') {
      // 1. Envoyer la réponse au serveur/autre joueur
      // sendMyAnswerToServer(localPlayerId!, index, isCorrect);

      // 2. Pour la simulation, on pourrait déclencher une réponse de l'adversaire après un délai
      //    (ceci est juste pour tester le flux sans vrai backend)
      // Future.delayed(Duration(seconds: Random().nextInt(3) + 1), () {
      //   if (!opponentPlayerHasAnsweredThisQuestion && mounted) {
      //     final opponentMockAnswerIndex = Random().nextInt(questions[currentQuestionIndex]['options'].length);
      //     final opponentMockCorrect = questions[currentQuestionIndex]['options'][opponentMockAnswerIndex] == correctAnswer;
      //     simulateOpponentAnswer(opponentMockAnswerIndex, opponentMockCorrect);
      //   }
      // });

      _checkIfProceedToNextQuestion();
    } else { // Mode Solo
      countdownTimer?.cancel(); // En solo, on arrête le timer dès que le joueur répond
      // Le bouton "Suivant" (ou un délai) gérera la suite
    }
  }

  void _checkIfProceedToNextQuestion() {
    if (widget.mode == 'Versus') {
      if (localPlayerHasAnsweredThisQuestion && opponentPlayerHasAnsweredThisQuestion) {
        countdownTimer?.cancel(); // Les deux ont répondu
        setState(() {
          bothPlayersAnsweredOrTimedOut = true;
        });
        // Attendre un peu pour montrer les résultats avant de passer à la question suivante
        Future.delayed(const Duration(seconds: 2), () { // Augmentez la durée si nécessaire
          goToNextQuestion();
        });
      }
      // Si le temps s'écoule, handleQuestionTimeout s'en chargera.
    }
    // En mode Solo, la progression est gérée par le bouton "Next" ou le timeout.
  }

  void goToNextQuestion() {
    if (!mounted) return;
    countdownTimer?.cancel();

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      startNewQuestion(); // Réinitialise tous les états nécessaires pour la nouvelle question
    } else {
      // Fin du quiz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultPage(
            totalQuestions: questions.length,
            correctAnswers: localPlayerCorrectAnswers, // Score du joueur local
            mode: widget.mode,
            // Pour le mode Versus, vous passeriez aussi le score de l'adversaire
            // opponentScore: opponentPlayerCorrectAnswers,
            // winnerId: déterminer le gagnant,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSolo = widget.mode == 'Solo';
    final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;

    if (isLoading) {
      return SpeLayout(child: const Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return SpeLayout(child: const Center(child: Text("Aucune question disponible")));
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = List<String>.from(currentQuestion['options']);
    final correctAnswerText = currentQuestion['answer'];

    return SpeLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isSolo && widget.versusData != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.person, color: Colors.deepPurple,
                            // Indicateur si le joueur local a répondu
                            semanticLabel: localPlayerHasAnsweredThisQuestion ? "Vous avez répondu" : "En attente de votre réponse"),
                        Text(widget.versusData!['players'][0]['username']  + (localPlayerHasAnsweredThisQuestion ? " (Répondu)" : "")),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.person_outline, color: Colors.redAccent,
                            // Indicateur si l'adversaire a répondu
                            semanticLabel: opponentPlayerHasAnsweredThisQuestion ? "Adversaire a répondu" : "En attente de l'adversaire"),
                        Text(widget.versusData!['players'][1]['username'] + (opponentPlayerHasAnsweredThisQuestion ? " (Répondu)" : "")),
                      ],
                    ),
                  ],
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                currentQuestion['image'],
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timeLeft / 10.0,
                backgroundColor: Colors.grey[300],
                color: primaryColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currentQuestion['question'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Message d'attente en mode Versus
            if (widget.mode == 'Versus' && localPlayerHasAnsweredThisQuestion && !opponentPlayerHasAnsweredThisQuestion && !bothPlayersAnsweredOrTimedOut)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "En attente de ${widget.versusData!['players'][1]['username']}...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
              ),

            ...List.generate(
              options.length,
                  (index) {
                final optionText = options[index];
                bool isCorrectOption = optionText == correctAnswerText;

                Color borderColor = Colors.grey.shade300;
                Color? tileColor = Colors.white;
                Icon? trailingIcon;

                bool shouldShowLocalPlayerAnswer = localPlayerHasAnsweredThisQuestion || bothPlayersAnsweredOrTimedOut;
                bool shouldShowOpponentAnswer = widget.mode == 'Versus' && (opponentPlayerHasAnsweredThisQuestion || bothPlayersAnsweredOrTimedOut);

                if (shouldShowLocalPlayerAnswer) {
                  if (index == localPlayerSelectedIndex) { // Option sélectionnée par le joueur local
                    borderColor = isCorrectOption ? Colors.green.shade700 : Colors.red.shade700;
                    tileColor = isCorrectOption ? Colors.green.shade100 : Colors.red.shade100;
                    trailingIcon = Icon(
                      isCorrectOption ? Icons.check_circle : Icons.cancel,
                      color: isCorrectOption ? Colors.green.shade700 : Colors.red.shade700,
                      semanticLabel: "Votre réponse",
                    );
                  } else if (isCorrectOption) { // Bonne réponse, non sélectionnée par le joueur local
                    borderColor = Colors.green.shade300;
                    // tileColor = Colors.green.withOpacity(0.05);
                  }
                }

                Widget optionContent = Text(
                  optionText,
                  style: const TextStyle(fontSize: 18),
                );

                if (shouldShowOpponentAnswer && index == opponentPlayerSelectedIndex && index != localPlayerSelectedIndex) {
                  // Si l'adversaire a choisi cette option et que ce n'est pas celle du joueur local
                  borderColor = Colors.blue.shade300; // Couleur pour la sélection de l'adversaire
                  tileColor = Colors.blue.shade50;
                  trailingIcon = Icon(
                    Icons.radio_button_checked, // Ou une autre icône pour l'adversaire
                    color: Colors.blue.shade700,
                    semanticLabel: "Réponse de l'adversaire",
                  );
                } else if (shouldShowOpponentAnswer && index == opponentPlayerSelectedIndex && index == localPlayerSelectedIndex) {
                  // Les deux ont choisi la même option
                  // Le style du joueur local (vert/rouge) prendra le dessus, mais on peut ajouter un indicateur
                  optionContent = Row(
                    children: [
                      Expanded(child: optionContent),
                      const SizedBox(width: 8),
                      Icon(Icons.people_alt_outlined, color: primaryColor, size: 20, semanticLabel: "Réponse des deux joueurs"),
                    ],
                  );
                }


                return GestureDetector(
                  onTap: () => onLocalPlayerAnswer(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2.5),
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
                        Expanded(child: optionContent),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Le bouton "Next" n'est affiché qu'en mode Solo et si le joueur a répondu
            if (isSolo && localPlayerHasAnsweredThisQuestion)
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
                  'Suivant',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            // Bouton pour simuler la réponse de l'adversaire (POUR DÉVELOPPEMENT UNIQUEMENT)
            if (widget.mode == 'Versus' && !opponentPlayerHasAnsweredThisQuestion && !bothPlayersAnsweredOrTimedOut && const bool.fromEnvironment("dart.vm.product") == false)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: [
                    Text("Outils de débogage (Versus):"),
                    ElevatedButton(
                      onPressed: () {
                        // Simule une réponse correcte de l'adversaire
                        int correctOptionIndex = options.indexOf(correctAnswerText);
                        simulateOpponentAnswer(correctOptionIndex, true);
                      },
                      child: Text("Simuler Adversaire Réponse Correcte"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Simule une réponse incorrecte de l'adversaire
                        int incorrectOptionIndex = (options.indexOf(correctAnswerText) + 1) % options.length;
                        simulateOpponentAnswer(incorrectOptionIndex, false);

                      },
                      child: Text("Simuler Adversaire Réponse Incorrecte"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        simulateOpponentTimeout();
                      },
                      child: Text("Simuler Adversaire Timeout"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}



// import 'dart:async';
// import 'dart:convert';
// import 'package:brain_match/ui/screens/quiz/quiz_result.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import '../../layout/special_layout.dart';
//
// class QuizPlayPage extends StatefulWidget {
//   final String categoryId;
//   final String mode;
//   final Map<String, dynamic>? versusData;
//
//
//   const QuizPlayPage({
//     super.key,
//     required this.categoryId,
//     required this.mode,
//     this.versusData,
//   });
//
//   @override
//   State<QuizPlayPage> createState() => _QuizPlayPageState();
// }
//
// class _QuizPlayPageState extends State<QuizPlayPage> {
//   List<dynamic> questions = [];
//   int currentQuestionIndex = 0;
//   bool isLoading = true;
//   int? selectedIndex;
//   bool hasAnswered = false;
//   int correctAnswers = 0;
//
//   Timer? countdownTimer;
//   double timeLeft = 10.0;
//
//   @override
//   void initState() {
//     // super.initState();
//     // fetchQuestionData().then((_) {
//     //   if (questions.isNotEmpty) startTimer();
//     // });
//     super.initState();
//     if (widget.mode == 'Versus' && widget.versusData != null) {
//       setState(() {
//         questions = List<Map<String, dynamic>>.from(widget.versusData!['quiz']['subTheme']['questions']);
//         isLoading = false;
//       });
//       startTimer();
//     } else {
//       fetchQuestionData().then((_) {
//         if (questions.isNotEmpty) startTimer();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     countdownTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> fetchQuestionData() async {
//     final baseUrl = dotenv.env['API_KEY'];
//     final url = '$baseUrl/quiz/question/${widget.categoryId}';
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           questions = List<Map<String, dynamic>>.from(data['subTheme']['questions']);
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Erreur ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur lors du chargement : $e')),
//         );
//       }
//     }
//   }
//
//   void startTimer() {
//     countdownTimer?.cancel();
//     setState(() {
//       timeLeft = 10;
//     });
//
//     countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (timeLeft <= 0) {
//         timer.cancel();
//         if (!hasAnswered) {
//           setState(() {
//             hasAnswered = true;
//           });
//           Future.delayed(const Duration(seconds: 1), () {
//             goToNextQuestion();
//           });
//         }
//       } else {
//         setState(() {
//           timeLeft -= 0.1;
//         });
//       }
//     });
//   }
//
//   void goToNextQuestion() {
//     countdownTimer?.cancel();
//     if (currentQuestionIndex < questions.length - 1) {
//       setState(() {
//         currentQuestionIndex++;
//         selectedIndex = null;
//         hasAnswered = false;
//         timeLeft = 10;
//       });
//       startTimer();
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => QuizResultPage(
//             totalQuestions: questions.length,
//             correctAnswers: correctAnswers,
//             mode: widget.mode,
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isSolo = widget.mode == 'Solo';
//     final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;
//
//     return SpeLayout(
//       child: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : questions.isEmpty
//           ? const Center(child: Text("Aucune question disponible"))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             if (!isSolo && widget.versusData != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Column(
//                       children: [
//                         const Icon(Icons.person, color: Colors.deepPurple),
//                         Text(widget.versusData!['players'][0]['username']),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const Icon(Icons.person_outline, color: Colors.redAccent),
//                         Text(widget.versusData!['players'][1]['username']),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 questions[currentQuestionIndex]['image'],
//                 height: 220,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: timeLeft / 10,
//                 backgroundColor: Colors.grey[300],
//                 color: primaryColor,
//                 minHeight: 10,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               questions[currentQuestionIndex]['question'],
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ...List.generate(
//               questions[currentQuestionIndex]['options'].length,
//                   (index) {
//                 final option = questions[currentQuestionIndex]['options'][index];
//                 final correctAnswer = questions[currentQuestionIndex]['answer'];
//                 final isCorrect = option == correctAnswer;
//                 final isSelected = index == selectedIndex;
//
//                 Color borderColor = Colors.grey.shade300;
//                 Icon? trailingIcon;
//
//                 if (hasAnswered) {
//                   if (isSelected) {
//                     borderColor = isCorrect ? Colors.green : Colors.red;
//                     trailingIcon = Icon(
//                       isCorrect ? Icons.check_circle : Icons.cancel,
//                       color: isCorrect ? Colors.green : Colors.red,
//                     );
//                   } else if (isCorrect) {
//                     borderColor = Colors.green;
//                     trailingIcon = const Icon(
//                       Icons.check_circle,
//                       color: Colors.green,
//                     );
//                   }
//                 }
//
//                 return GestureDetector(
//                   onTap: () {
//                     if (!hasAnswered) {
//                       setState(() {
//                         selectedIndex = index;
//                         hasAnswered = true;
//                         if (isCorrect) correctAnswers++;
//                       });
//                       countdownTimer?.cancel();
//                     }
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: borderColor, width: 3),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             option,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                         if (trailingIcon != null) trailingIcon,
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 30),
//             if (hasAnswered)
//               ElevatedButton(
//                 onPressed: goToNextQuestion,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text(
//                   'Next',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }