import 'dart:async';
import 'package:brain_match/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class IaRouter extends ConsumerStatefulWidget {
  final String token;
  final String theme;

  const IaRouter({
    super.key,
    required this.token,
    required this.theme,
  });

  @override
  ConsumerState<IaRouter> createState() => _IaRouterState();
}

class _IaRouterState extends ConsumerState<IaRouter> {
  final _controller = StreamController<IaEvent>.broadcast();
  late final SocketClient _socket;

  late String roomId;
  int totalQuestions = 0;

  double timeLeft = 12000;
  Timer? countdownTimer;

  String? selectedAnswer;
  String? correctAnswer;
  Map<String, dynamic>? currentQuestion;

  List<Map<String, dynamic>> playerQuestions = [];

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
          timeLeft = 120;
          selectedAnswer = null;
          correctAnswer = null;
          playerQuestions = [];
          currentQuestion = null;
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
          timeLeft = 120;
          selectedAnswer = null;
          correctAnswer = null;
          currentQuestion = data['question'] as Map<String, dynamic>?;
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

        if (currentQuestion != null && selectedAnswer != null) {
          playerQuestions.add({
            "question": currentQuestion,
            "answer": selectedAnswer,
            "correct": selectedAnswer == data['correctAnswer'],
          });
        }
      },
      onGameOver: (data) {
        countdownTimer?.cancel();
        if (!mounted) return;

        // On récupère les infos utilisateur depuis Riverpod
        final user = ref.read(currentUserProvider);
        final username = user?.username ?? '';
        final imageUrl = user?.picture ?? '';

        final resultData = {
          "score": data['score'],
          "totalQuestions": totalQuestions,
          "players": [
            {
              "username": username,
              "image": imageUrl,
              "questions": playerQuestions,
            }
          ]
        };

        _controller.add(IaEvent(state: IaState.result, data: resultData));
      },
      onOpponentLeft: (_) {},
    );

    _socket.joinGameIa(widget.theme);
  }

  void startTimer() {
    countdownTimer?.cancel();
    if (!mounted) return;

    final startTime = DateTime.now();
    const totalTime = Duration(seconds: 12);

    countdownTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final remaining = totalTime - elapsed;

      if (remaining <= Duration.zero) {
        timer.cancel();
        if (!mounted) return;
        setState(() => timeLeft = 0);
      } else {
        if (!mounted) return;
        setState(() => timeLeft = remaining.inMilliseconds.toDouble());
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
    // On récupère le user **en direct** depuis le provider
    final user = ref.watch(currentUserProvider);
    final username = user?.username ?? '';
    final imageUrl = user?.picture ?? '';

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
              timeLeft: timeLeft.toInt(),
              selectedAnswer: selectedAnswer,
              correctAnswer: correctAnswer,
              onAnswer: (answer) {
                if (!mounted) return;
                selectedAnswer = answer;

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
          // On s'assure que les infos user sont mises à jour
            final resultData = Map<String, dynamic>.from(event.data);
            if (resultData['players'] != null && resultData['players'] is List) {
              resultData['players'][0]['username'] = username;
              resultData['players'][0]['image'] = imageUrl;
            }

            return ResultView(resultData: resultData);

          case IaState.error:
            return ErrorView(message: event.data);
        }
      },
    );
  }
}
