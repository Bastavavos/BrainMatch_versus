import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();
  factory SocketClient() => _instance;

  late IO.Socket socket;

  SocketClient._internal();

  void connect({
    required String username,
    required String categoryId,
    required Function(dynamic data) onStartGame,
    required Function(Map<String, dynamic>) onQuestionResult,
    Function(String)? onError,
  }) {
    socket = IO.io('http://192.168.1.67:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connecté au serveur socket');

      socket.emit('join_game', {
        'username': username,
        'categoryId': categoryId,
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
      if (onError != null) {
        onError(data['message'] ?? 'Erreur inconnue');
      }
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


// import 'package:socket_io_client/socket_io_client.dart' as io;
//
// void connectToSocket() {
//   final socket = io.io('http://192.168.1.67:3000', <String, dynamic>{
//     'transports': ['websocket'],
//     'autoConnect': false,
//   });
//
//   socket.connect();
//
//   socket.onConnect((_) {
//     print('Connected to the socket server');
//   });
//
//   socket.onDisconnect((_) {
//     print('Disconnected from the socket server');
//   });
//
//   socket.on('message', (data) {
//     print('Received message: $data');
//   });
//
//   // Add more event listeners and functionality as needed.
//
//   // To send a message to the server, use:
//   // socket.emit('eventName', 'message data');
// }