import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import '../../../resources/socket_client.dart';

class ChessGamePage extends StatefulWidget {
  final String token;

  const ChessGamePage({super.key, required this.token});

  @override
  State<ChessGamePage> createState() => _ChessGamePageState();
}

class _ChessGamePageState extends State<ChessGamePage> {
  final ChessBoardController _controller = ChessBoardController();
  final socketClient = SocketClient();

  String? roomId;
  bool isMyTurn = false;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();

    socketClient.connectToChessGame(
      token: widget.token,
      onStartGame: (room, youPlayWhite) {
        setState(() {
          roomId = room;
          isMyTurn = youPlayWhite;
          gameStarted = true;
        });
      },
      onMovePlayed: (from, to) {
        _controller.makeMove(from: from, to: to);
        setState(() {
          isMyTurn = true;
        });
      },
      onOpponentLeft: () {
        _showDialog("L'adversaire a quitté la partie.");
      },
      onError: (msg) {
        _showDialog("Erreur : $msg");
      },
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Partie terminée"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/main')),
            child: const Text("Retour"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    socketClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Échecs en ligne")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChessBoard(
              controller: _controller,
              boardColor: BoardColor.green,
              enableUserMoves: isMyTurn,
              onMove: () {
                if (!isMyTurn || roomId == null) return;
                final sanMoves = _controller.getSan();
                if (sanMoves.isNotEmpty) {
                  final lastMove = sanMoves.last!;
                  final from = lastMove.substring(0, 2);
                  final to = lastMove.substring(2);
                  socketClient.sendChessMove(roomId: roomId!, from: from, to: to);
                  setState(() { isMyTurn = false; });
                }
              },
            ),
            const SizedBox(height: 20),
            Text(isMyTurn ? "Votre tour" : "Tour de l'adversaire"),
          ],
        ),
      ),
    );
  }
}
