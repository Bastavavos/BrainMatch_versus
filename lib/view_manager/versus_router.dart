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
          final opponent = extractOpponent(data['players']);

          if (opponent == null) {
            _controller.add(VersusEvent(
              state: VersusState.error,
              data: "Adversaire introuvable",
            ));
            return;
          }

          _controller.add(VersusEvent(state: VersusState.beforeMatch, data: {
            'opponent': opponent,
          }));
        },

        onGameStart: handleGameStart,

        onNewQuestion: (data) {
          if (!mounted) return;
          questionTimerStarted = false;

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

  Map<String, dynamic>? extractOpponent(List<dynamic>? players) {
    if (players == null) return null;

    return players.firstWhere(
          (p) => p['_id'] != currentUserId,
      orElse: () => null,
    );
  }

  void handleGameStart(dynamic data) {
    if (!mounted) return;

    roomId = data['roomId'];
    totalQuestions = data['totalQuestions'];

    final opponent = extractOpponent(data['players']);
    if (opponent == null) {
      _controller.add(VersusEvent(
        state: VersusState.error,
        data: "Adversaire non trouvé.",
      ));
      return;
    }

    _controller.add(VersusEvent(
      state: VersusState.question,
      data: {
        ...data,
        'totalQuestions': totalQuestions,
      },
    ));
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
            return BeforeMatchView(
              opponent: event.data['opponent'],
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

