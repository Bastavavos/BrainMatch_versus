import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/socket_manager.dart';
import '../provider/user_provider.dart';
import '../ui/screens/quiz/before_match_view.dart';
import '../ui/widgets/error_view.dart';
import '../ui/screens/quiz/opponent_left_view.dart';
import '../ui/screens/quiz/question_view.dart';
import '../ui/screens/quiz/result_view.dart';
import '../ui/screens/quiz/waiting_view.dart';

enum VersusState {
  waiting,
  beforeMatch,
  question,
  result,
  opponentLeft,
  error,
}

class VersusEvent {
  final VersusState state;
  final dynamic data;

  VersusEvent({required this.state, this.data});
}

class VersusRouter extends ConsumerStatefulWidget {
  final String token;
  final String categoryId;

  const VersusRouter({
    super.key,
    required this.token,
    required this.categoryId,
  });

  @override
  ConsumerState<VersusRouter> createState() => _VersusRouterState();
}

class _VersusRouterState extends ConsumerState<VersusRouter> {
  final _controller = StreamController<VersusEvent>.broadcast();
  late final SocketClient _socket;

  late String roomId;
  int totalQuestions = 0;
  String? currentUserId;

  double timeLeft = 12000;
  Timer? countdownTimer;
  String? selectedAnswer;
  String? correctAnswer;

  bool questionTimerStarted = false;

  // --- Nouveaux champs pour garder l'historique comme en Solo/Ia ---
  final List<Map<String, dynamic>> playerQuestions = [];
  Map<String, dynamic>? currentQuestion;

  // --- On conserve l'adversaire reçu dans onPrepareGame ---
  Map<String, dynamic>? opponentPlayer;

  @override
  void initState() {
    super.initState();
    _socket = SocketClient();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      currentUserId = user?.id;

      if (currentUserId == null) {
        _controller.add(VersusEvent(
          state: VersusState.error,
          data: "Utilisateur non authentifié.",
        ));
        return;
      }

      _socket.connect(
        token: widget.token,
        onError: (msg) {
          if (!mounted) return;
          _controller.add(VersusEvent(state: VersusState.error, data: msg));
        },

        onPrepareGame: (data) {
          // Extract opponent and save it locally for later (onGameOver)
          final opponent = extractOpponent(data['players']);
          if (opponent == null) {
            _controller.add(VersusEvent(
              state: VersusState.error,
              data: "Adversaire introuvable",
            ));
            return;
          }

          // sauvegarde l'adversaire pour usage ultérieur
          opponentPlayer = opponent;

          _controller.add(VersusEvent(state: VersusState.beforeMatch, data: {
            'opponent': opponent,
          }));
        },

        onGameStart: (data) {
          // Réinitialisations au démarrage de la partie
          if (!mounted) return;
          roomId = data['roomId'];
          totalQuestions = data['totalQuestions'] ?? totalQuestions;

          setState(() {
            timeLeft = 120;
            selectedAnswer = null;
            correctAnswer = null;
            playerQuestions.clear();
            currentQuestion = null;
            questionTimerStarted = false;
          });

          _controller.add(VersusEvent(
            state: VersusState.question,
            data: {
              ...data,
              'totalQuestions': totalQuestions,
            },
          ));
        },

        onNewQuestion: (data) {
          if (!mounted) return;

          questionTimerStarted = false;

          // mémorise la question courante et reset la réponse sélectionnée
          currentQuestion = data['question'] as Map<String, dynamic>?;
          selectedAnswer = null;
          correctAnswer = null;

          _controller.add(VersusEvent(state: VersusState.question, data: {
            ...data,
            'totalQuestions': totalQuestions,
          }));
        },

        onAnswerFeedback: (data) {
          if (!mounted) return;

          setState(() {
            correctAnswer = data['correctAnswer'];
          });

          // stocke la réponse du joueur courant (si on a bien une question et une réponse sélectionnée)
          if (currentQuestion != null && selectedAnswer != null) {
            playerQuestions.add({
              "question": currentQuestion,
              "answer": selectedAnswer,
              "correct": selectedAnswer == data['correctAnswer'],
            });

            // évite d'ajouter plusieurs fois la même réponse si on reçoit plusieurs feedbacks :
            selectedAnswer = null;
          }
        },

        onGameOver: (data) {
          // Le backend n'envoie rien : on reconstruit le résultat localement
          debugPrint('onGameOver payload from server: $data');
          countdownTimer?.cancel();
          if (!mounted) return;

          final user = ref.read(currentUserProvider);
          if (user == null) {
            _controller.add(VersusEvent(
              state: VersusState.error,
              data: "Utilisateur non authentifié.",
            ));
            return;
          }

          if (opponentPlayer == null) {
            _controller.add(VersusEvent(
              state: VersusState.error,
              data: "Adversaire non sauvegardé.",
            ));
            return;
          }

          // Calcul du score du joueur courant :
          // priorité : score renvoyé par le backend (data['score']), sinon calcul local (nombres de correct)
          final int myScoreFromBackend = (data['score'] is int) ? data['score'] as int : -1;
          final int myLocalCorrectCount =
              playerQuestions.where((q) => q['correct'] == true).length;
          final int computedMyScore = myScoreFromBackend >= 0 ? myScoreFromBackend : myLocalCorrectCount;

          // Essaie de récupérer le score de l'adversaire si disponible dans opponentPlayer ou payload
          final int opponentScoreFromOpponentObject =
          (opponentPlayer!['score'] is int) ? opponentPlayer!['score'] as int : -1;
          final int opponentScoreFromBackend =
          (data['opponentScore'] is int) ? data['opponentScore'] as int : -1;
          final int computedOpponentScore = opponentScoreFromOpponentObject >= 0
              ? opponentScoreFromOpponentObject
              : (opponentScoreFromBackend >= 0 ? opponentScoreFromBackend : 0);

          // --- Mon joueur (current) ---
          final Map<String, dynamic> currentPlayer = {
            'username': user.username ,
            'image': user.picture ,
            'score': computedMyScore,
            'questions': List<Map<String, dynamic>>.from(playerQuestions),
          };

          // --- L’adversaire (conservé depuis onPrepareGame) ---
          final Map<String, dynamic> opponent = {
            'username': opponentPlayer!['username'] ?? opponentPlayer!['name'] ?? 'Adversaire',
            'image': opponentPlayer!['image'] ?? opponentPlayer!['picture'] ?? '',
            'score': computedOpponentScore,
          };

          final resultPayload = {
            'players': [currentPlayer, opponent],
            'totalQuestions': totalQuestions,
          };

          _controller.add(VersusEvent(state: VersusState.result, data: resultPayload));
        },

        onOpponentLeft: (data) {
          countdownTimer?.cancel();
          if (!mounted) return;
          _controller.add(VersusEvent(state: VersusState.opponentLeft, data: data));
        },
      );

      _socket.joinGameVersus(widget.categoryId);
      _controller.add(VersusEvent(state: VersusState.waiting));
    });
  }

  /// Extrait l'adversaire depuis un payload qui peut être List ou Map
  Map<String, dynamic>? extractOpponent(dynamic players) {
    if (players == null) return null;

    try {
      if (players is List) {
        for (final p in players) {
          if (p is Map && p['_id'] != currentUserId) {
            return Map<String, dynamic>.from(p);
          }
        }
      } else if (players is Map) {
        for (final v in players.values) {
          if (v is Map && v['_id'] != currentUserId) {
            return Map<String, dynamic>.from(v);
          }
        }
      }
    } catch (e) {
      debugPrint('extractOpponent error: $e');
    }

    return null;
  }

  void startTimer() {
    countdownTimer?.cancel();
    if (!mounted) return;

    setState(() {
      timeLeft = 120;
    });

    final startTime = DateTime.now();
    const totalTime = Duration(seconds: 12);

    countdownTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final remaining = totalTime - elapsed;

      if (remaining <= Duration.zero) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          timeLeft = 0;
        });
      } else {
        if (!mounted) return;
        setState(() {
          timeLeft = remaining.inMilliseconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _controller.close();
    _socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VersusEvent>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = snapshot.data!;

        switch (event.state) {
          case VersusState.waiting:
            return const WaitingView();

          case VersusState.beforeMatch:
            return BeforeMatchView(
              opponent: event.data['opponent'],
            );

          case VersusState.question:
            if (!questionTimerStarted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  timeLeft = 120;
                  selectedAnswer = null;
                  correctAnswer = null;
                  questionTimerStarted = true;
                });
                startTimer();
              });
            }
            return QuestionView(
              questionData: event.data['question'],
              questionIndex: event.data['questionIndex'],
              totalQuestions: event.data['totalQuestions'],
              timeLeft: timeLeft.toInt(),
              selectedAnswer: selectedAnswer,
              correctAnswer: correctAnswer,
              onAnswer: (answer) {
                if (!mounted) return;
                setState(() {
                  selectedAnswer = answer;
                });

                _socket.sendAnswer(
                  roomId: roomId,
                  questionIndex: event.data['questionIndex'],
                  answer: answer,
                );
              },
            );

          case VersusState.result:
            return ResultView(
              resultData: event.data, // players: [currentPlayer, opponentPlayer], totalQuestions
            );

          case VersusState.opponentLeft:
            return OpponentLeftView(message: event.data['message']);

          case VersusState.error:
            return ErrorView(message: event.data.toString());
        }
      },
    );
  }
}
