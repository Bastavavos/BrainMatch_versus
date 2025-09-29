import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? _socket;
  bool _isInitialized = false;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String token,
    required Function(String message) onError,
    Function(dynamic data)? onPrepareGame,
    required Function(dynamic data) onGameStart,
    required Function(dynamic data) onNewQuestion,
    required Function(dynamic data) onAnswerFeedback,
    required Function(dynamic data) onGameOver,
    required Function(dynamic data) onOpponentLeft,
  }) {
    disconnect();

    _socket = IO.io(
      'http://192.168.1.94:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.connect();

    // Nettoyage ciblé : supprime tous les anciens listeners
    _socket?.offAny();

    // Supprime explicitement chaque callback AVANT de le réaffecter
    _socket
      ?..off('connect')
      ..onConnect((_) {
        print('✅ Connecté au serveur Socket');
        _isInitialized = true;
      });

    _socket
      ?..off('error')
      ..on('error', (data) {
        print('⚠️ Erreur Socket: $data');
        onError(data['message']);
      });

    if (onPrepareGame != null) {
      _socket
        ?..off('prepare_game')
        ..on('prepare_game', (data) {
          print('🎮 Préparation de la partie : $data');
          onPrepareGame(data);
        });
    }

    _socket
      ?..off('start_game')
      ..on('start_game', onGameStart);

    _socket
      ?..off('new_question')
      ..on('new_question', onNewQuestion);

    _socket
      ?..off('answer_feedback')
      ..on('answer_feedback', onAnswerFeedback);

    _socket
      ?..off('game_over')
      ..on('game_over', onGameOver);

    _socket
      ?..off('opponent_left')
      ..on('opponent_left', onOpponentLeft);

    _socket
      ?..off('disconnect')
      ..onDisconnect((_) {
        print('❌ Déconnecté');
        _isInitialized = false;
      });
  }

  void joinGameSolo(String categoryId) {
    _socket?.emit('join_game_solo', {'categoryId': categoryId});
  }

  void joinGameVersus(String categoryId) {
    _socket?.emit('join_game_versus', {'categoryId': categoryId});
  }

  void joinGameIa(String theme) {
    _socket?.emit('join_game_ia', {'theme': theme});
  }

  void sendAnswer({
    required String roomId,
    required int questionIndex,
    required String answer,
  }) {
    _socket?.emit('player_answer', {
      'roomId': roomId,
      'questionIndex': questionIndex,
      'answer': answer,
    });
  }

  void disconnect() {
    if (_socket != null) {
      _socket?.offAny(); // Supprime tous les listeners existants
      _socket?.disconnect();
      _socket?.destroy();
      _socket = null;
      _isInitialized = false;
    }
  }
}
