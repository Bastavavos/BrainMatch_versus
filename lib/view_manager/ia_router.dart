import 'dart:async';
import 'package:flutter/material.dart';

import '../network/socket_manager.dart';
import '../ui/widgets/error_view.dart';
import '../ui/screens/quiz/question_view.dart';
import '../ui/screens/quiz/result_view.dart';
import '../ui/widgets/ia/loading_ia.dart';

enum IaState {
  question,
  result,
  error,
}

class IaEvent {
  final IaState state;
  final dynamic data;

  IaEvent({required this.state, this.data});
}

class IaRouter extends StatefulWidget {
  final String token;
  final String theme;

  const IaRouter({
    super.key,
    required this.token,
    required this.theme,
  });

  @override
  State<IaRouter> createState() => _IaRouterState();
}

class _IaRouterState extends State<IaRouter> {
  final _controller = StreamController<IaEvent>.broadcast();
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
        _controller.add(IaEvent(state: IaState.error, data: msg));
      },
      onGameStart: (data) {
        if (!mounted) return;
        roomId = data['roomId'];
        totalQuestions = data['totalQuestions'];

        setState(() {
          timeLeft = 100;
          selectedAnswer = null;
          correctAnswer = null;
        });
        startTimer();

        _controller.add(IaEvent(
          state: IaState.question,
          data: data,
        ));
      },
      onNewQuestion: (data) {
        if (!mounted) return;

        setState(() {
          timeLeft = 100;
          selectedAnswer = null;
          correctAnswer = null;
        });
        startTimer();

        _controller.add(IaEvent(state: IaState.question, data: {
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

        _controller.add(IaEvent(state: IaState.result, data: data));
      },
      onOpponentLeft: (_) {},
    );

    _socket.joinGameIa(widget.theme);
  }

  void startTimer() {
    countdownTimer?.cancel();
    if (!mounted) return;

    setState(() {
      timeLeft = 100;
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timeLeft <= 0) {
        timer.cancel();
      } else {
        if (!mounted) return;
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
    return StreamBuilder<IaEvent>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingContent();
        }

        final event = snapshot.data!;

        switch (event.state) {
          case IaState.question:
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

          case IaState.result:
            return ResultView(resultData: event.data);

          case IaState.error:
            return ErrorView(message: event.data);
        }
      },
    );
  }
}
