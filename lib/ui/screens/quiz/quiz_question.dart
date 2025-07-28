// import 'dart:async';
// import 'dart:convert';
// import 'package:brain_match/ui/screens/quiz/quiz_result.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import '../../../resources/socket_client.dart';
// import '../../layout/special_layout.dart';
//
// class QuizPlayPage extends StatefulWidget {
//   final String categoryId;
//   final String mode;
//   final Map<String, dynamic>? versusData;
//   final String currentUser;
//   final String token;
//
//   const QuizPlayPage({
//     super.key,
//     required this.categoryId,
//     required this.mode,
//     this.versusData,
//     required this.currentUser,
//     required this.token,
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
//   bool opponentHasAnswered = false;
//
//   Timer? countdownTimer;
//   double timeLeft = 10.0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.mode == 'Versus' && widget.versusData != null) {
//       final question = widget.versusData!['question'];
//       if (question != null) {
//         questions = [question]; // initialize just one question
//       }
//       isLoading = false;
//
//       SocketClient().connect(
//         token: widget.token,
//         categoryId: widget.categoryId,
//         onStartGame: (_) {
//         },
//         onNewQuestion: handleNewQuestion,
//         onAnswerFeedback: handleAnswerFeedback,
//         onGameOver: handleGameOver,
//         onError: (message) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Erreur socket : $message')),
//             );
//           }
//         },
//         onOpponentLeft: () {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Votre adversaire a quitté la partie.')),
//             );
//             Navigator.pop(context);
//           }
//         },
//       );
//
//     }
//     else {
//       fetchQuestionData().then((_) {
//         if (questions.isNotEmpty) startTimer();
//       });
//     }
//   }
//
//   ///////////////////// ajout reco socket /////////////////
//   // void reconnectSocket() {
//   //   SocketClient().reconnect(
//   //     token: widget.token,
//   //     categoryId: widget.categoryId,
//   //     onStartGame: (_) {
//   //       // Si nécessaire
//   //     },
//   //     onNewQuestion: handleNewQuestion,
//   //     onAnswerFeedback: handleAnswerFeedback,
//   //     onGameOver: handleGameOver,
//   //     onError: (message) {
//   //       if (mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           SnackBar(content: Text('Erreur socket : $message')),
//   //         );
//   //       }
//   //     },
//   //     onOpponentLeft: () {
//   //       if (mounted) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Votre adversaire a quitté la partie.')),
//   //         );
//   //         Navigator.pop(context);
//   //       }
//   //     },
//   //   );
//   // }
//
//   //////////////////////////////////////////////
//
//   @override
//   void dispose() {
//     countdownTimer?.cancel();
//     SocketClient().disconnect();
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
//   // Méthode générique pour accéder aux données selon le mode
//   dynamic getQuestionValue(String key) {
//     if (questions.isEmpty) return null;
//     if (widget.mode == 'Solo') {
//       return questions[currentQuestionIndex][key];
//     } else {
//       return questions.first[key];
//     }
//   }
//
// // Getters pratiques
//   String get questionText => getQuestionValue('question') ?? '';
//   String get imageUrl => getQuestionValue('image') ?? '';
//   List get options => (getQuestionValue('options') as List?) ?? [];
//   String get correctAnswer => getQuestionValue('answer') ?? '';
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
//         }
//         if (widget.mode != 'Versus') {
//           Future.delayed(const Duration(seconds: 1), () {
//             goToNextQuestion();
//           });
//         }
//       } else {
//         setState(() {
//           timeLeft -= 0.1;
//           if (timeLeft < 0) timeLeft = 0;
//         });
//       }
//     });
//   }
//
//   void goToNextQuestion() {
//     countdownTimer?.cancel();
//     if (widget.mode == 'Versus') return;
//     if (currentQuestionIndex < questions.length - 1) {
//       setState(() {
//         currentQuestionIndex++;
//         selectedIndex = null;
//         hasAnswered = false;
//         opponentHasAnswered = false;
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
//   void handleNewQuestion(Map<String, dynamic> data) {
//     if (!mounted) return;
//
//     final question = data['question'];
//     if (question == null) return;
//
//     setState(() {
//       currentQuestionIndex =  data['questionIndex'] ?? 0;
//       questions = [question];
//       selectedIndex = null;
//       hasAnswered = false;
//       opponentHasAnswered = false;
//       timeLeft = 10;
//     });
//     if (widget.mode == 'Versus') {
//       startTimer();
//     }
//     debugPrint("Nouvelle question reçue: ${jsonEncode(data)}");
//   }
//
//   void handleAnswerFeedback(Map<String, dynamic> data) {
//     if (!mounted) return;
//
//     final player = data['player'];
//     final bool isCurrentUser = player == widget.currentUser;
//     final bool correct = data['correct'] ?? false;
//
//     setState(() {
//       if (isCurrentUser) {
//         hasAnswered = true;
//         if (correct) correctAnswers++;
//       } else {
//         opponentHasAnswered = true;
//       }
//     });
//   }
//
//   void handleGameOver(Map<String, dynamic> data) {
//     if (!mounted) return;
//
//     countdownTimer?.cancel();
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => QuizResultPage(
//           totalQuestions: questions.length,
//           correctAnswers: correctAnswers,
//           mode: widget.mode,
//         ),
//       ),
//     );
//   }
//
//   String versusImageUrl(String url) {
//     return url.replaceAll("localhost", "192.168.1.74"); // ← remplace par l'IP de ton backend
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
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 widget.mode == 'Solo' ? imageUrl : versusImageUrl(imageUrl),
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
//             const SizedBox(height: 16),
//             Text(
//               "Question ${currentQuestionIndex + 1} / ${isSolo ? questions.length : '10'}",
//               style: TextStyle(color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               questionText,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             if (!hasAnswered && opponentHasAnswered)
//               Padding(
//                 padding: const EdgeInsets.only(top: 12.0),
//                 child: Text(
//                   "L'adversaire a répondu",
//                   style: const TextStyle(color: Colors.redAccent),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             const SizedBox(height: 24),
//             ...List.generate(options.length, (index) {
//               final option = options[index];
//               final isCorrect = option == correctAnswer;
//               final isSelected = index == selectedIndex;
//
//               Color borderColor = Colors.grey.shade300;
//               Icon? trailingIcon;
//
//               if (hasAnswered) {
//                 if (isSelected) {
//                   borderColor = isCorrect ? Colors.green : Colors.red;
//                   trailingIcon = Icon(
//                     isCorrect ? Icons.check_circle : Icons.cancel,
//                     color: isCorrect ? Colors.green : Colors.red,
//                   );
//                 } else if (isCorrect) {
//                   borderColor = Colors.green;
//                   trailingIcon = const Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                   );
//                 }
//               }
//
//               return GestureDetector(
//                 onTap: () {
//                   if (!hasAnswered) {
//                     setState(() {
//                       selectedIndex = index;
//                       hasAnswered = true;
//                       if (isCorrect) correctAnswers++;
//                     });
//                     countdownTimer?.cancel();
//
//                     if (widget.mode == 'Versus' &&
//                         widget.versusData != null) {
//                       SocketClient().sendAnswer(
//                         roomId: widget.versusData!['roomId'],
//                         questionIndex: currentQuestionIndex,
//                         answer: option,
//                       );
//                     }
//                   }
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   padding: const EdgeInsets.symmetric(
//                       vertical: 16, horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: borderColor, width: 3),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           option,
//                           style: const TextStyle(fontSize: 18),
//                         ),
//                       ),
//                       if (trailingIcon != null) trailingIcon,
//                     ],
//                   ),
//                 ),
//               );
//             }),
//             const SizedBox(height: 30),
//             if (hasAnswered && isSolo)
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
