import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;

  late IO.Socket socket;

  SocketClient._internal();

  void connect({
    required String token,
    required String categoryId,
    required String currentUser,
    required Function(dynamic data) onStartGame,
    required Function(Map<String, dynamic>) onQuestionResult,
    Function(String)? onError,
    bool isHost = false,
  }) {
    // socket = IO.io('http://192.168.1.67:3000', <String, dynamic>{
    //   'transports': ['websocket'],
    //   'autoConnect': false,
    // });
    final baseUrl = dotenv.env['API_KEY'];
    socket = IO.io(
      '$baseUrl',
      // 'http://192.168.1.74:3000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({
        'token': token,
      })
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connecté au serveur');

      socket.emit('join_game', {
        'categoryId': categoryId,
        'isHost': isHost,
      });
    });

    socket.on('start_game', (data) {
      print('🎮 Partie lancée ! Données reçues : $data');
      onStartGame(data);
    });

    socket.on('question_result', (data) {
      print('📩 Résultat question reçu : $data');
      onQuestionResult(Map<String, dynamic>.from(data));
    });

    socket.on('error', (data) {
      print('⚠️ Erreur socket : $data');
      onError?.call(data['message'] ?? 'Erreur inconnue');
    });

    socket.onDisconnect((_) {
      print('🔌 Déconnecté du serveur socket');
    });
  }

  void sendAnswer({
    required String roomId,
    required int questionIndex,
    required String answer,
    required String username,
  }) {
    socket.emit('player_answer', {
      'roomId': roomId,
      'questionIndex': questionIndex,
      'answer': answer,
      'username': username,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}