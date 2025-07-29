import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/socket_manager.dart';
import '../provider/user_provider.dart';
import '../ui/screens/new_screen/before_match_view.dart';
import '../ui/screens/new_screen/error_view.dart';
import '../ui/screens/new_screen/opponent_left_view.dart';
import '../ui/screens/new_screen/question_view.dart';
import '../ui/screens/new_screen/result_view.dart';
import '../ui/screens/new_screen/waiting_view.dart';

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
  bool readyToStartFirstQuestion = false;
  Map<String, dynamic>? pendingFirstQuestion;

  final _controller = StreamController<VersusEvent>.broadcast();
  late final SocketClient _socket;

  late String roomId;
  int totalQuestions = 0;
  String? currentUserId;

  int timeLeft = 100;
  Timer? countdownTimer;
  String? selectedAnswer;
  String? correctAnswer;

  bool questionTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _socket = SocketClient();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      currentUserId = user?['_id'];

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
        onGameStart: handleGameStart,
        onNewQuestion: (data) {
          if (!mounted) return;

          questionTimerStarted = false;

          if (!readyToStartFirstQuestion) {
            pendingFirstQuestion = data;
            return;
          }

          // setState(() {
          //   timeLeft = 100;
          //   selectedAnswer = null;
          //   correctAnswer = null;
          // });
          //
          // startTimer();

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
        },
        onGameOver: (data) {
          countdownTimer?.cancel();
          if (!mounted) return;
          _controller.add(VersusEvent(state: VersusState.result, data: data));
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

  void handleGameStart(dynamic data) {
    if (!mounted) return;

    print("Données reçues dans onGameStart: $data");

    roomId = data['roomId'];
    totalQuestions = data['totalQuestions'];

    final players = data['players'];
    if (players == null || players is! List || players.length < 2) {
      _controller.add(VersusEvent(
        state: VersusState.error,
        data: "Joueurs invalides.",
      ));
      return;
    }

    final opponent = players.firstWhere(
          (p) => p['_id'] != currentUserId,
      orElse: () => null,
    );

    if (opponent == null || opponent is! Map<String, dynamic>) {
      _controller.add(VersusEvent(
        state: VersusState.error,
        data: "Adversaire non trouvé.",
      ));
      return;
    }

    _controller.add(VersusEvent(state: VersusState.beforeMatch, data: {
      'opponent': opponent,
      'gameData': data,
    }));
  }

  void startTimer() {
    countdownTimer?.cancel();
    if (!mounted) return;

    setState(() {
      timeLeft = 100;
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (timeLeft <= 0) {
        timer.cancel();
      } else {
        setState(() {
          timeLeft--;
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
            final opponentData = event.data?['opponent'];
            final gameData = event.data?['gameData'];

            if (opponentData == null || opponentData is! Map<String, dynamic>) {
              return const ErrorView(message: "Données adversaire manquantes.");
            }

            return BeforeMatchView(
              opponent: opponentData,
              onCountdownComplete: () {
                if (!mounted || gameData == null) return;

                // Marquer comme prêt à recevoir la première question
                setState(() {
                  readyToStartFirstQuestion = true;
                });

                // Informer le serveur
                _socket.sendReadyForFirstQuestion(gameData['roomId']);

                // Si une question était déjà reçue avant la fin du compte à rebours, on peut l'afficher maintenant
                if (pendingFirstQuestion != null) {
                  _controller.add(VersusEvent(
                    state: VersusState.question,
                    data: {
                      ...pendingFirstQuestion!,
                      'totalQuestions': totalQuestions,
                    },
                  ));
                  pendingFirstQuestion = null;
                }

                // readyToStartFirstQuestion = true;


                // setState(() {
                //   timeLeft = 100;
                //   selectedAnswer = null;
                //   correctAnswer = null;
                // });

                // startTimer();


                // Future.delayed(const Duration(milliseconds: 300), () {
                //   if (!mounted) return;
                //   _controller.add(
                //     VersusEvent(state: VersusState.question, data: gameData),
                //   );
                // }); //TODO à changer

                // _controller.add(
                //     VersusEvent(state: VersusState.question, data: gameData));

              },
            );

          case VersusState.question:
            if (!questionTimerStarted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  timeLeft = 100;
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
              timeLeft: timeLeft,
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
            return ResultView(resultData: event.data);

          case VersusState.opponentLeft:
            return OpponentLeftView(message: event.data['message']);

          case VersusState.error:
            return ErrorView(message: event.data.toString());
        }
      },
    );
  }
}


