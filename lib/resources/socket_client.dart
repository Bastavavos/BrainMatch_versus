import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;

  late IO.Socket socket;

  SocketClient._internal();

  void connect({
    required String token,
    required String categoryId,
    required Function(dynamic data) onStartGame,
    required Function(Map<String, dynamic>) onNewQuestion,
    required Function(Map<String, dynamic>) onAnswerFeedback,
    required Function(Map<String, dynamic>) onGameOver,
    Function(String)? onError,
    Function()? onOpponentLeft,
  }) {
    socket = IO.io(
      'http://192.168.1.74:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({
        'token': token,
      }).build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connecté au serveur');

      socket.emit('join_game', {
        'categoryId': categoryId,
      });
    });

    socket.on('start_game', (data) {
      print('🎮 Partie lancée ! Données reçues : $data');
      onStartGame(data);
    });

    socket.on('new_question', (data) {
      print('❓ Nouvelle question : $data');
      onNewQuestion(Map<String, dynamic>.from(data));
    });

    socket.on('answer_feedback', (data) {
      print('✅ Feedback de réponse : $data');
      onAnswerFeedback(Map<String, dynamic>.from(data));
    });

    socket.on('game_over', (data) {
      print('🏁 Fin de partie : $data');
      onGameOver(Map<String, dynamic>.from(data));
    });

    socket.on('opponent_left', (data) {
      print('🚪 Adversaire a quitté : $data');
      if (onOpponentLeft != null) {
        onOpponentLeft();
      }
    });

    socket.on('error', (data) {
      print('⚠️ Erreur socket : $data');
      onError?.call(data['message'] ?? 'Erreur inconnue');
    });

    socket.onDisconnect((_) {
      print('🔌 Déconnecté du serveur socket');
    });
  }

  /////////////////// ajout reco
  void reconnect({
    required String token,
    required String categoryId,
    required Function(dynamic data) onStartGame,
    required Function(Map<String, dynamic>) onNewQuestion,
    required Function(Map<String, dynamic>) onAnswerFeedback,
    required Function(Map<String, dynamic>) onGameOver,
    Function(String)? onError,
    Function()? onOpponentLeft,
  }) {
    print('🔄 Reconnexion au serveur socket...');
    socket.disconnect();
    connect(
      token: token,
      categoryId: categoryId,
      onStartGame: onStartGame,
      onNewQuestion: onNewQuestion,
      onAnswerFeedback: onAnswerFeedback,
      onGameOver: onGameOver,
      onError: onError,
      onOpponentLeft: onOpponentLeft,
    );
  }

  ///////////////////////////////////////////

  void sendAnswer({
    required String roomId,
    required int questionIndex,
    required String answer,
  }) {
    socket.emit('player_answer', {
      'roomId': roomId,
      'questionIndex': questionIndex,
      'answer': answer,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
