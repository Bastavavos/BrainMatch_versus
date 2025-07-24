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
  final _socket = SocketClient();

  late String roomId;
  int totalQuestions = 0;

  @override
  void initState() {
    super.initState();

    _socket.connect(
      token: widget.token,
      onError: (msg) {
        _controller.add(VersusEvent(state: VersusState.error, data: msg));
      },
      onGameStart: (data) {
        roomId = data['roomId'];
        totalQuestions = data['totalQuestions'];
        _controller.add(VersusEvent(state: VersusState.question, data: data));
      },
      onNewQuestion: (data) {
        _controller.add(VersusEvent(state: VersusState.question, data: {
          ...data,
          'totalQuestions': totalQuestions, // injecter manuellement
        }));
      },
      onAnswerFeedback: (data) {
        // Optionnel : afficher feedback dans la UI avec local state
      },
      onGameOver: (data) {
        _controller.add(VersusEvent(state: VersusState.result, data: data));
      },
      onOpponentLeft: (data) {
        _controller.add(VersusEvent(state: VersusState.opponentLeft, data: data));
      },
    );

    // Lance la recherche d'adversaire
    _socket.joinGameVersus(widget.categoryId);

    // Affiche vue d’attente
    _controller.add(VersusEvent(state: VersusState.waiting));
  }

  @override
  void dispose() {
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

          case VersusState.question:
            return QuestionView(
              questionData: event.data['question'],
              questionIndex: event.data['questionIndex'],
              totalQuestions: event.data['totalQuestions'],
              onAnswer: (answer) {
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
