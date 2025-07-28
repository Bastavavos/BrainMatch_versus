import 'dart:async';
import 'package:flutter/material.dart';

import '../network/socket_manager.dart';
import '../ui/screens/new_screen/error_view.dart';
import '../ui/screens/new_screen/opponent_left_view.dart';
import '../ui/screens/new_screen/question_view.dart';
import '../ui/screens/new_screen/result_view.dart';
import '../ui/screens/new_screen/waiting_view.dart';

enum VersusState {
  waiting,
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

class VersusRouter extends StatefulWidget {
  final String token;
  final String categoryId;

  const VersusRouter({
    super.key,
    required this.token,
    required this.categoryId,
  });

  @override
  State<VersusRouter> createState() => _VersusRouterState();
}

class _VersusRouterState extends State<VersusRouter> {
  final _controller = StreamController<VersusEvent>.broadcast();
  late final SocketClient _socket;

  late String roomId;
  int totalQuestions = 0;

  int timeLeft = 100;
  Timer? countdownTimer;

  String? selectedAnswer;
  String? correctAnswer;

  @override
  void initState() {
    super.initState();

    _socket = SocketClient();

    _socket.connect(
      token: widget.token,
      onError: (msg) {
        if (!mounted) return;
        _controller.add(VersusEvent(state: VersusState.error, data: msg));
      },
      // onGameStart: (data) {
      //   if (!mounted) return;
      //
      //   roomId = data['roomId'];
      //   totalQuestions = data['totalQuestions'];
      //
      //   setState(() {
      //     timeLeft = 100;
      //     selectedAnswer = null;
      //     correctAnswer = null;
      //   });
      //
      //   startTimer();
      //
      //   _controller.add(VersusEvent(state: VersusState.question, data: data));
      // },

      onGameStart: (data) {
        if (!mounted) return;

        roomId = data['roomId'];
        totalQuestions = data['totalQuestions'];

        final opponent = data['opponent'];


        // ✅ D'abord, affiche les deux joueurs dans WaitingView
        _controller.add(VersusEvent(
          state: VersusState.waiting,
          data: {
            'opponent': opponent,
            'questionData': data,
          },
        ));

        // ⏱️ Démarre le timer de transition ici (2 secondes)
        Future.delayed(const Duration(seconds: 8), () {
          if (!mounted) return;

          setState(() {
            timeLeft = 100;
            selectedAnswer = null;
            correctAnswer = null;
          });

          startTimer();

          _controller.add(VersusEvent(
            state: VersusState.question,
            data: data,
          ));
        });
      },

      onNewQuestion: (data) {
        if (!mounted) return;

        setState(() {
          timeLeft = 100;
          selectedAnswer = null;
          correctAnswer = null;
        });

        startTimer();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.add(VersusEvent(state: VersusState.waiting));
      }
    });

    // _controller.add(VersusEvent(state: VersusState.waiting));
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
            return WaitingView(
              opponent: event.data?['opponent'],
            );

          case VersusState.question:
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
            return ErrorView(message: event.data);
        }
      },
    );
  }
}


