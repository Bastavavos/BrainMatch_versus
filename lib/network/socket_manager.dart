import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;

  IO.Socket? socket;

  SocketClient._internal();

  void connect({
    required String token,
    required Function(String message) onError,
    required Function(dynamic data) onGameStart,
    required Function(dynamic data) onNewQuestion,
    required Function(dynamic data) onAnswerFeedback,
    required Function(dynamic data) onGameOver,
    required Function(dynamic data) onOpponentLeft,
  }) {
    socket = IO.io(
      'http://192.168.1.74:3000',
      // 'http://192.168.1.17:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    // Events
    socket?.onConnect((_) {
      print('✅ Connecté au serveur Socket');
    });

    socket?.on('error', (data) {
      onError(data['message']);
    });

    socket?.on('start_game', (data) {
      onGameStart(data);
    });

    socket?.on('new_question', (data) {
      onNewQuestion(data);
    });

    socket?.on('answer_feedback', (data) {
      onAnswerFeedback(data);
    });

    socket?.on('game_over', (data) {
      onGameOver(data);
    });

    socket?.on('opponent_left', (data) {
      onOpponentLeft(data);
    });

    socket?.onDisconnect((_) {
      print('❌ Déconnecté');
    });
  }

  void joinGameSolo(String categoryId) {
    socket?.emit('join_game_solo', {'categoryId': categoryId});
  }

  void joinGameVersus(String categoryId) {
    socket?.emit('join_game_versus', {'categoryId': categoryId});
  }

  void sendAnswer({
    required String roomId,
    required int questionIndex,
    required String answer,
  }) {
    socket?.emit('player_answer', {
      'roomId': roomId,
      'questionIndex': questionIndex,
      'answer': answer,
    });
  }

  void disconnect() {
    socket?.disconnect();
  }
}
