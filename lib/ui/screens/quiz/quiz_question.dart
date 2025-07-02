import 'dart:async';
import 'dart:convert'; // Utilisé si vous avez besoin de jsonEncode/Decode pour des données complexes avec le socket
// Assurez-vous d'importer votre package socket_io_client
// import 'package:socket_io_client/socket_io_client.dart' as IO; // Exemple d'importation

import 'package:brain_match/ui/screens/quiz/quiz_result.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../layout/special_layout.dart';

// --- Début des modifications pour l'intégration Socket.IO ---
// Supposons que vous initialisez et passez votre instance de socket au widget QuizPlayPage
// ou qu'elle est accessible via un provider/service.
// Pour cet exemple, je vais supposer qu'elle est passée ou accessible globalement.
// Exemple : IO.Socket socket = yourSocketService.socket;
// --- Fin des modifications pour l'intégration Socket.IO ---


enum VersusPlayerAction { answered, timeExpired }

class PlayerAnswerEvent {
  final String playerId;
  final int? selectedOptionIndex;
  final bool isCorrect;
  final VersusPlayerAction action;

  PlayerAnswerEvent({
    required this.playerId,
    this.selectedOptionIndex,
    required this.isCorrect,
    required this.action,
  });
}

class QuizPlayPage extends StatefulWidget {
  final String categoryId;
  final String mode;
  final Map<String, dynamic>? versusData;
  // Ajoutez votre instance de socket ici si vous la passez en paramètre
  // final IO.Socket socket; // Exemple

  const QuizPlayPage({
    super.key,
    required this.categoryId,
    required this.mode,
    this.versusData,
    // required this.socket, // Exemple
  });

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;

  int? localPlayerSelectedIndex;
  bool localPlayerHasAnsweredThisQuestion = false;
  int localPlayerCorrectAnswers = 0;

  String? localPlayerId; // Sera extrait de versusData
  String? opponentPlayerId; // Sera extrait de versusData
  String? opponentUsername; // Pour l'affichage
  int? opponentPlayerSelectedIndex;
  bool opponentPlayerHasAnsweredThisQuestion = false;
  // int opponentPlayerCorrectAnswers = 0; // Si vous voulez suivre le score de l'adversaire

  bool bothPlayersAnsweredOrTimedOut = false;

  Timer? countdownTimer;
  double timeLeft = 10.0;

  // StreamController pour simuler les actions de l'adversaire si vous n'avez pas de connexion socket immédiate
  // Mais avec un vrai backend, les événements viendront du socket.
  // final StreamController<PlayerAnswerEvent> _opponentActionsController = StreamController.broadcast();
  // Stream<PlayerAnswerEvent> get opponentActions => _opponentActionsController.stream;

  // --- Début des modifications pour l'intégration Socket.IO ---
  late String currentRoomId; // Pour stocker le roomId actuel
  bool _isMounted = false; // Pour vérifier si le widget est monté avant setState

  // Remplacez 'yourSocketInstance' par la manière dont vous accédez à votre socket.
  // Exemple : IO.Socket socket = YourSocketProvider.of(context).socket;
  // Ou si passé en paramètre : widget.socket

  // !!! IMPORTANT !!!
  // Assurez-vous que votre instance de socket (par exemple `socket`) est correctement
  // initialisée et connectée AVANT d'arriver sur cette page.
  // Vous devriez probablement la passer en paramètre au constructeur de QuizPlayPage
  // ou l'obtenir via un gestionnaire d'état (Provider, Riverpod, BLoC, etc.).
  // Pour cet exemple, je vais supposer que vous avez une variable `socket` accessible.
  // Exemple: final IO.Socket socket = GlobalSocketService.instance.socket;

  // --- Fin des modifications pour l'intégration Socket.IO ---


  @override
  void initState() {
    super.initState();
    _isMounted = true;

    if (widget.mode == 'Versus' && widget.versusData != null) {
      // Extraction des données du versusData
      currentRoomId = widget.versusData!['roomId'] as String;
      final players = widget.versusData!['players'] as List<dynamic>;
      // Déterminez qui est le joueur local et l'adversaire.
      // Cela dépend de la structure de vos données et de comment vous identifiez le joueur local.
      // Supposons que vous avez un 'localUserId' quelque part pour comparer.
      // Pour cet exemple, je vais supposer une logique simple si vous avez un ID utilisateur local.
      // String localUserId = YourAuthService.userId; // Exemple
      // localPlayerId = players.firstWhere((p) => p['id'] == localUserId)['id'];
      // opponentPlayerId = players.firstWhere((p) => p['id'] != localUserId)['id'];
      // opponentUsername = players.firstWhere((p) => p['id'] != localUserId)['username'];

      // Si vous n'avez pas d'ID local pour comparer directement,
      // et que le backend vous donne les joueurs dans un ordre spécifique,
      // vous pourriez avoir besoin d'une info supplémentaire pour savoir qui est qui.
      // Pour l'instant, faisons une supposition basée sur l'ordre,
      // mais CELA DEVRA ÊTRE ADAPTÉ À VOTRE LOGIQUE D'IDENTIFICATION DU JOUEUR LOCAL.
      // Par exemple, si le premier joueur dans la liste est toujours le joueur local :
      // localPlayerId = players[0]['id'] ?? 'player1_fallback';
      // opponentPlayerId = players[1]['id'] ?? 'player2_fallback';
      // opponentUsername = players[1]['username'] ?? 'Adversaire';

      // Pour l'affichage, il est plus simple si le backend envoie directement les infos
      // du joueur local et de l'adversaire de manière distincte pour chaque client.
      // Si `versusData` contient `localPlayerId` envoyé par le backend :
      localPlayerId = widget.versusData!['localPlayerId'] ?? players[0]['id']; // Assurez-vous que ces clés existent
      final opponentData = players.firstWhere((p) => p['id'] != localPlayerId, orElse: () => players[1]);
      opponentPlayerId = opponentData['id'];
      opponentUsername = opponentData['username'];


      questions = List<Map<String, dynamic>>.from(widget.versusData!['quiz']['subTheme']['questions']);
      isLoading = false;

      _setupSocketListeners(); // Configurer les écouteurs de socket pour le jeu
      startNewQuestion();
    } else { // Mode Solo
      fetchQuestionData().then((_) {
        if (_isMounted && questions.isNotEmpty) {
          startNewQuestion();
        }
      });
    }
  }

  void _setupSocketListeners() {
    if (widget.mode != 'Versus') return;

    // IMPORTANT: Remplacez `GlobalSocketService.instance.socket` par votre instance de socket
    final socket = GlobalSocketService.instance.socket; // EXEMPLE D'ACCÈS AU SOCKET

    // Écouter les réponses de l'adversaire
    socket.on('player_answered', (data) { // Assurez-vous que le nom de l'event correspond à votre backend
      if (!_isMounted) return;
      // data devrait contenir : { playerId: 'id_adversaire', selectedOptionIndex: int, isCorrect: bool, roomId: 'id_room' }
      if (data['roomId'] == currentRoomId && data['playerId'] == opponentPlayerId) {
        setState(() {
          opponentPlayerHasAnsweredThisQuestion = true;
          opponentPlayerSelectedIndex = data['selectedOptionIndex'] as int?;
          // if (data['isCorrect'] as bool? ?? false) {
          //   opponentPlayerCorrectAnswers++;
          // }
          _checkIfProceedToNextQuestion();
        });
      }
    });

    // Écouter si l'adversaire a expiré son temps (si votre backend envoie cet événement)
    socket.on('player_timed_out', (data){ // Assurez-vous que le nom de l'event correspond
      if (!_isMounted) return;
      if (data['roomId'] == currentRoomId && data['playerId'] == opponentPlayerId) {
        setState(() {
          opponentPlayerHasAnsweredThisQuestion = true; // Marquer comme ayant "fini" son tour
          opponentPlayerSelectedIndex = null; // Pas de sélection
          _checkIfProceedToNextQuestion();
        });
      }
    });


    // Écouter la fin de la partie initiée par le serveur
    socket.on('game_ended', (data) {
      if (!_isMounted) return;
      if (data['roomId'] == currentRoomId) {
        print('Partie terminée par le serveur pour la room $currentRoomId: ${data['message']}');
        countdownTimer?.cancel();
        // Le joueur est déjà sur la page de résultat ou y sera redirigé par goToNextQuestion
        // si c'est la dernière question. Le serveur confirme juste ici.
        // Vous pourriez vouloir afficher un dialogue ou un snackbar.
        if (ModalRoute.of(context)?.isCurrent ?? false) { // Si cette page est toujours active
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'La partie est terminée!')),
          );
          // Potentiellement forcer la navigation si ce n'est pas déjà fait
          if (currentQuestionIndex >= questions.length -1) {
            // Déjà géré par goToNextQuestion, mais pour être sûr
          } else {
            // La partie s'est terminée prématurément (ex: déconnexion de l'autre)
            // Naviguer vers les résultats avec le score actuel
            _navigateToResults();
          }
        }
      }
    });

    // Écouter la déconnexion de l'adversaire
    socket.on('opponent_disconnected', (data) {
      if (!_isMounted) return;
      // `data` pourrait contenir le roomId ou être un événement global
      // Pour cet exemple, on suppose qu'il n'y a qu'une partie active pour ce socket.
      print('Adversaire déconnecté: ${data['message']}');
      countdownTimer?.cancel();
      if (_isMounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Adversaire Déconnecté'),
              content: Text(data['message'] ?? 'Votre adversaire a quitté la partie.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Ferme le dialogue
                    _navigateToResults(opponentDisconnected: true); // Navigue vers la page des résultats
                  },
                ),
              ],
            );
          },
        );
      }
    });

    // Nettoyer les écouteurs lors du dispose du widget
    // Ceci est généralement fait dans la méthode dispose, mais pour les listeners de socket,
    // il est important de les retirer spécifiquement pour éviter les fuites de mémoire
    // ou les appels multiples si la page est reconstruite.
    // Le nettoyage des listeners spécifiques est mieux fait dans dispose().
  }


  @override
  void dispose() {
    _isMounted = false;
    countdownTimer?.cancel();

    // --- Début des modifications pour l'intégration Socket.IO ---
    if (widget.mode == 'Versus') {
      // IMPORTANT: Remplacez `GlobalSocketService.instance.socket` par votre instance de socket
      final socket = GlobalSocketService.instance.socket; // EXEMPLE D'ACCÈS AU SOCKET

      // Retirer les listeners spécifiques à cette page pour éviter les fuites
      socket.off('player_answered');
      socket.off('player_timed_out');
      socket.off('game_ended');
      socket.off('opponent_disconnected');
      // Ne pas appeler socket.disconnect() ici sauf si c'est la fin de la session utilisateur.
      // Le serveur gère le `leave(roomId)`.
    }
    // --- Fin des modifications pour l'intégration Socket.IO ---
    super.dispose();
  }

  Future<void> fetchQuestionData() async {
    final baseUrl = dotenv.env['API_KEY'];
    final url = '$baseUrl/quiz/question/${widget.categoryId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        if (!_isMounted) return;
        final data = jsonDecode(response.body);
        setState(() {
          questions = List<Map<String, dynamic>>.from(data['subTheme']['questions']);
          isLoading = false;
        });
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      if (!_isMounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement : $e')),
      );
    }
  }

  void startNewQuestion() {
    countdownTimer?.cancel();
    if (!_isMounted) return;
    setState(() {
      timeLeft = 10.0;
      localPlayerSelectedIndex = null;
      localPlayerHasAnsweredThisQuestion = false;
      opponentPlayerSelectedIndex = null;
      opponentPlayerHasAnsweredThisQuestion = false;
      bothPlayersAnsweredOrTimedOut = false;
    });

    countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isMounted) {
        timer.cancel();
        return;
      }
      if (timeLeft <= 0) {
        timer.cancel();
        handleQuestionTimeout();
      } else {
        if (widget.mode == 'Versus' && localPlayerHasAnsweredThisQuestion && opponentPlayerHasAnsweredThisQuestion) {
          timer.cancel();
          // _checkIfProceedToNextQuestion est déjà appelé par la dernière action de réponse.
        }
        if (_isMounted) {
          setState(() {
            timeLeft -= 0.1;
          });
        }
      }
    });
  }

  void handleQuestionTimeout() {
    if (!_isMounted || bothPlayersAnsweredOrTimedOut) return;

    if (widget.mode == 'Versus') {
      // Informer le serveur que le joueur local a expiré son temps
      // IMPORTANT: Remplacez `GlobalSocketService.instance.socket` par votre instance de socket
      final socket = GlobalSocketService.instance.socket; // EXEMPLE D'ACCÈS AU SOCKET
      if (!localPlayerHasAnsweredThisQuestion) {
        socket.emit('player_action', { // ou un nom d'event comme 'player_timed_out_on_question'
          'roomId': currentRoomId,
          'playerId': localPlayerId,
          'action': 'timeout', // ou type: VersusPlayerAction.timeExpired.toString()
        });
      }
    }

    setState(() {
      bothPlayersAnsweredOrTimedOut = true;
      if (!localPlayerHasAnsweredThisQuestion) {
        localPlayerHasAnsweredThisQuestion = true;
      }
      if (widget.mode == 'Versus' && !opponentPlayerHasAnsweredThisQuestion) {
        // On suppose que si le serveur ne nous a pas dit que l'adversaire a répondu,
        // et que le temps est écoulé, l'adversaire a aussi expiré.
        // Le serveur pourrait aussi envoyer un événement pour confirmer cela.
        opponentPlayerHasAnsweredThisQuestion = true;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_isMounted) goToNextQuestion();
    });
  }

  void onLocalPlayerAnswer(int index) {
    if (localPlayerHasAnsweredThisQuestion || bothPlayersAnsweredOrTimedOut) return;

    final option = questions[currentQuestionIndex]['options'][index];
    final correctAnswer = questions[currentQuestionIndex]['answer'];
    final isCorrect = option == correctAnswer;

    if (_isMounted) {
      setState(() {
        localPlayerSelectedIndex = index;
        localPlayerHasAnsweredThisQuestion = true;
        if (isCorrect) {
          localPlayerCorrectAnswers++;
        }
      });
    }

    if (widget.mode == 'Versus') {
      // --- Début des modifications pour l'intégration Socket.IO ---
      // Envoyer la réponse au serveur
      // IMPORTANT: Remplacez `GlobalSocketService.instance.socket` par votre instance de socket
      final socket = GlobalSocketService.instance.socket; // EXEMPLE D'ACCÈS AU SOCKET

      socket.emit('player_action', { // Ou un nom d'événement comme 'submit_answer'
        'roomId': currentRoomId,
        'playerId': localPlayerId,
        'questionIndex': currentQuestionIndex, // Optionnel, pour vérification serveur
        'selectedOptionIndex': index,
        'isCorrect': isCorrect,
        'action': 'answered', // ou type: VersusPlayerAction.answered.toString()
      });
      // --- Fin des modifications pour l'intégration Socket.IO ---
      _checkIfProceedToNextQuestion();
    } else { // Mode Solo
      countdownTimer?.cancel();
    }
  }

  void _checkIfProceedToNextQuestion() {
    if (widget.mode == 'Versus') {
      if (localPlayerHasAnsweredThisQuestion && opponentPlayerHasAnsweredThisQuestion) {
        countdownTimer?.cancel();
        if (_isMounted) {
          setState(() {
            bothPlayersAnsweredOrTimedOut = true;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (_isMounted) goToNextQuestion();
          });
        }
      }
    }
    // En mode Solo, la progression est gérée par le bouton "Next" ou le timeout.
  }

  void _navigateToResults({bool opponentDisconnected = false}) {
    if (!_isMounted) return;

    // En mode Versus, informer le serveur que le quiz est terminé pour ce client
    // Cela correspond à l'événement `game_over_request_${roomId}` que votre backend attend
    if (widget.mode == 'Versus' && widget.versusData != null) {
      // IMPORTANT: Remplacez `GlobalSocketService.instance.socket` par votre instance de socket
      final socket = GlobalSocketService.instance.socket; // EXEMPLE D'ACCÈS AU SOCKET
      socket.emit('game_over_request_${currentRoomId}'); // Le nom de l'event doit correspondre EXACTEMENT
      print("Événement game_over_request_${currentRoomId} envoyé au serveur.");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultPage(
          totalQuestions: questions.length,
          correctAnswers: localPlayerCorrectAnswers,
          mode: widget.mode,
          versusData: widget.versusData,
          opponentDisconnected: opponentDisconnected,
          // Vous pourriez vouloir passer le score de l'adversaire si vous l'avez et qu'il est pertinent
          // opponentScore: opponentPlayerCorrectAnswers,
          // winnerId: déterminer le gagnant si cette logique est côté client
        ),
      ),
    );
  }

  void goToNextQuestion() {
    if (!_isMounted) return;
    countdownTimer?.cancel();

    if (currentQuestionIndex < questions.length - 1) {
      if (_isMounted) {
        setState(() {
          currentQuestionIndex++;
        });
        startNewQuestion();
      }
    } else {
      _navigateToResults();
    }
  }


  @override
  Widget build(BuildContext context) {
    // ... (votre méthode build reste globalement la même)
    // Assurez-vous d'utiliser `opponentUsername` pour afficher le nom de l'adversaire.
    // Exemple dans la section d'affichage des joueurs :
    // Text(opponentUsername ?? 'Adversaire' + (opponentPlayerHasAnsweredThisQuestion ? " (Répondu)" : "")),

    // Le reste du code de build est similaire à votre version précédente,
    // mais il utilisera les états mis à jour par les événements socket.
    // Je vais le recopier avec les ajustements mineurs pour la clarté.

    final bool isSolo = widget.mode == 'Solo';
    final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;

    if (isLoading) {
      return SpeLayout(child: const Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return SpeLayout(child: Center(child: Text(widget.mode == 'Versus' ? "En attente des données du quiz..." : "Aucune question disponible")));
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = List<String>.from(currentQuestion['options']);
    final correctAnswerText = currentQuestion['answer'];

    return SpeLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isSolo && widget.versusData != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.person, color: Colors.deepPurple,
                            semanticLabel: localPlayerHasAnsweredThisQuestion ? "Vous avez répondu" : "En attente de votre réponse"),
                        Text((widget.versusData!['players'] as List).firstWhere((p) => p['id'] == localPlayerId, orElse: () => {'username': 'Joueur 1'})['username'] + (localPlayerHasAnsweredThisQuestion ? " (Répondu)" : "")),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.person_outline, color: Colors.redAccent,
                            semanticLabel: opponentPlayerHasAnsweredThisQuestion ? "Adversaire a répondu" : "En attente de l'adversaire"),
                        Text((opponentUsername ?? 'Adversaire') + (opponentPlayerHasAnsweredThisQuestion ? " (Répondu)" : "")),
                      ],
                    ),
                  ],
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                currentQuestion['image'],
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 220,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.error_outline, color: Colors.red, size: 50)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: timeLeft / 10.0,
                backgroundColor: Colors.grey[300],
                color: primaryColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              currentQuestion['question'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (widget.mode == 'Versus' && localPlayerHasAnsweredThisQuestion && !opponentPlayerHasAnsweredThisQuestion && !bothPlayersAnsweredOrTimedOut)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "En attente de ${opponentUsername ?? 'l\'adversaire'}...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[700]),
                ),
              ),

            ...List.generate(
              options.length,
                  (index) {
                final optionText = options[index];
                bool isCorrectOption = optionText == correctAnswerText;

                Color borderColor = Colors.grey.shade300;
                Color? tileColor = Colors.white; // Default tile color
                Icon? trailingIcon;

                bool showLocalAnswerHighlight = localPlayerHasAnsweredThisQuestion || bothPlayersAnsweredOrTimedOut;
                bool showOpponentSelectionHighlight = widget.mode == 'Versus' && (opponentPlayerHasAnsweredThisQuestion || bothPlayersAnsweredOrTimedOut) && opponentPlayerSelectedIndex == index;


                Widget optionContent = Text(optionText, style: const TextStyle(fontSize: 18));

                // Priorité à l'affichage de la réponse du joueur local
                if (showLocalAnswerHighlight) {
                  if (index == localPlayerSelectedIndex) {
                    borderColor = isCorrectOption ? Colors.green.shade700 : Colors.red.shade700;
                    tileColor = isCorrectOption ? Colors.green.shade100 : Colors.red.shade100;
                    trailingIcon = Icon(
                      isCorrectOption ? Icons.check_circle : Icons.cancel,
                      color: isCorrectOption ? Colors.green.shade700 : Colors.red.shade700,
                      semanticLabel: "Votre réponse",
                    );
                  } else if (isCorrectOption && bothPlayersAnsweredOrTimedOut) {
                    // Montrer la bonne réponse si le joueur local ne l'a pas choisie et que la question est finie
                    borderColor = Colors.green.shade300;
                    // tileColor = Colors.green.withOpacity(0.05); // Optionnel pour la bonne réponse non choisie
                  }
                }

                // Si l'adversaire a choisi cette option et que ce n'est pas celle du joueur local (ou si le joueur local n'a pas encore répondu)
                if (showOpponentSelectionHighlight) {
                  if (index == localPlayerSelectedIndex) { // Les deux ont choisi la même option
                    // Le style du joueur local (vert/rouge) a déjà été appliqué.
                    // On ajoute un indicateur "les deux joueurs"
                    optionContent = Row(
                      children: [
                        Expanded(child: Text(optionText, style: const TextStyle(fontSize: 18))),
                        const SizedBox(width: 8),
                        Icon(Icons.people_alt_outlined, color: primaryColor.withOpacity(0.7), size: 20, semanticLabel: "Réponse des deux joueurs"),
                      ],
                    );
                  } else if (index != localPlayerSelectedIndex && (bothPlayersAnsweredOrTimedOut || opponentPlayerHasAnsweredThisQuestion)) {
                    // L'adversaire a choisi cette option, différente du joueur local, ou le joueur local n'a pas répondu
                    borderColor = Colors.blue.shade300; // Couleur pour la sélection de l'adversaire
                    tileColor = tileColor == Colors.white ? Colors.blue.shade50 : tileColor; // Ne pas écraser la couleur de la réponse correcte/incorrecte du joueur local si elle est déjà définie
                    if (trailingIcon == null) { // N'ajoute l'icône de l'adversaire que si le joueur local n'a pas fait ce choix
                      trailingIcon = Icon(
                        Icons.radio_button_checked,
                        color: Colors.blue.shade700,
                        semanticLabel: "Réponse de l'adversaire",
                      );
                    }
                  }
                }


                return GestureDetector(
                  onTap: () => onLocalPlayerAnswer(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: optionContent),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            if (isSolo && localPlayerHasAnsweredThisQuestion)
              ElevatedButton(
                onPressed: goToNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Suivant',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            // Les boutons de débogage pour simuler l'adversaire ne sont plus nécessaires
            // si vous avez une vraie connexion socket.
          ],
        ),
      ),
    );
  }
}

// Classe d'exemple pour accéder à une instance globale du socket.
// Dans une vraie application, utilisez un Provider, GetIt, Riverpod, etc.
class GlobalSocketService {
  static final GlobalSocketService instance = GlobalSocketService._internal();
  // late IO.Socket socket; // Décommentez et initialisez votre socket ici

  factory GlobalSocketService() {
    return instance;
  }

  GlobalSocketService._internal() {
    // Initialisez votre socket ici. Par exemple :
    // socket = IO.io('YOUR_SOCKET_SERVER_URL', <String, dynamic>{
    //   'transports': ['websocket'],
    //   'autoConnect': false, // Connectez manuellement lorsque c'est nécessaire
    // });
    // socket.connect();
    // print("Socket service initialized and attempt to connect.");
  }

  // Pour cet exemple, je vais créer une fausse instance de socket
  // pour éviter les erreurs de compilation si vous n'avez pas socket_io_client.
  dynamic get socket {
    // REMPLACEZ CECI PAR VOTRE VRAIE INSTANCE DE SOCKET
    return _MockSocket();
  }
}

// Classe Mock pour l'exemple, à remplacer par votre vraie instance de socket
class _MockSocket {
  void emit(String event, [dynamic data]) {
    print("MOCK SOCKET: Emit event '$event' with data: $data");
  }
  void on(String event, Function handler) {
    print("MOCK SOCKET: Register handler for event '$event'");
  }
  void off(String event, [Function? handler]) {
    print("MOCK SOCKET: Unregister handler for event '$event'");
  }
// Ajoutez d'autres méthodes de socket si nécessaire (connect, disconnect, etc.)
}



// import 'dart:async';
// import 'dart:convert';
// import 'package:brain_match/ui/screens/quiz/quiz_result.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// import '../../layout/special_layout.dart';
//
// class QuizPlayPage extends StatefulWidget {
//   final String categoryId;
//   final String mode;
//   final Map<String, dynamic>? versusData;
//
//
//   const QuizPlayPage({
//     super.key,
//     required this.categoryId,
//     required this.mode,
//     this.versusData,
//   });
//
//   @override
//   State<QuizPlayPage> createState() => _QuizPlayPageState();
// }
//
// class _QuizPlayPageState extends State<QuizPlayPage> {
//   List<dynamic> questions = [];
//   int currentQuestionIndex = 0;
//   bool isLoading = true;
//   int? selectedIndex;
//   bool hasAnswered = false;
//   int correctAnswers = 0;
//
//   Timer? countdownTimer;
//   double timeLeft = 10.0;
//
//   @override
//   void initState() {
//     // super.initState();
//     // fetchQuestionData().then((_) {
//     //   if (questions.isNotEmpty) startTimer();
//     // });
//     super.initState();
//     if (widget.mode == 'Versus' && widget.versusData != null) {
//       setState(() {
//         questions = List<Map<String, dynamic>>.from(widget.versusData!['quiz']['subTheme']['questions']);
//         isLoading = false;
//       });
//       startTimer();
//     } else {
//       fetchQuestionData().then((_) {
//         if (questions.isNotEmpty) startTimer();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     countdownTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<void> fetchQuestionData() async {
//     final baseUrl = dotenv.env['API_KEY'];
//     final url = '$baseUrl/quiz/question/${widget.categoryId}';
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           questions = List<Map<String, dynamic>>.from(data['subTheme']['questions']);
//           isLoading = false;
//         });
//       } else {
//         throw Exception("Erreur ${response.statusCode}");
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Erreur lors du chargement : $e')),
//         );
//       }
//     }
//   }
//
//   void startTimer() {
//     countdownTimer?.cancel();
//     setState(() {
//       timeLeft = 10;
//     });
//
//     countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (timeLeft <= 0) {
//         timer.cancel();
//         if (!hasAnswered) {
//           setState(() {
//             hasAnswered = true;
//           });
//           Future.delayed(const Duration(seconds: 1), () {
//             goToNextQuestion();
//           });
//         }
//       } else {
//         setState(() {
//           timeLeft -= 0.1;
//         });
//       }
//     });
//   }
//
//   void goToNextQuestion() {
//     countdownTimer?.cancel();
//     if (currentQuestionIndex < questions.length - 1) {
//       setState(() {
//         currentQuestionIndex++;
//         selectedIndex = null;
//         hasAnswered = false;
//         timeLeft = 10;
//       });
//       startTimer();
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => QuizResultPage(
//             totalQuestions: questions.length,
//             correctAnswers: correctAnswers,
//             mode: widget.mode,
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isSolo = widget.mode == 'Solo';
//     final Color primaryColor = isSolo ? Colors.deepPurple : Colors.redAccent;
//
//     return SpeLayout(
//       child: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : questions.isEmpty
//           ? const Center(child: Text("Aucune question disponible"))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             if (!isSolo && widget.versusData != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Column(
//                       children: [
//                         const Icon(Icons.person, color: Colors.deepPurple),
//                         Text(widget.versusData!['players'][0]['username']),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         const Icon(Icons.person_outline, color: Colors.redAccent),
//                         Text(widget.versusData!['players'][1]['username']),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: Image.network(
//                 questions[currentQuestionIndex]['image'],
//                 height: 220,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: timeLeft / 10,
//                 backgroundColor: Colors.grey[300],
//                 color: primaryColor,
//                 minHeight: 10,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               questions[currentQuestionIndex]['question'],
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ...List.generate(
//               questions[currentQuestionIndex]['options'].length,
//                   (index) {
//                 final option = questions[currentQuestionIndex]['options'][index];
//                 final correctAnswer = questions[currentQuestionIndex]['answer'];
//                 final isCorrect = option == correctAnswer;
//                 final isSelected = index == selectedIndex;
//
//                 Color borderColor = Colors.grey.shade300;
//                 Icon? trailingIcon;
//
//                 if (hasAnswered) {
//                   if (isSelected) {
//                     borderColor = isCorrect ? Colors.green : Colors.red;
//                     trailingIcon = Icon(
//                       isCorrect ? Icons.check_circle : Icons.cancel,
//                       color: isCorrect ? Colors.green : Colors.red,
//                     );
//                   } else if (isCorrect) {
//                     borderColor = Colors.green;
//                     trailingIcon = const Icon(
//                       Icons.check_circle,
//                       color: Colors.green,
//                     );
//                   }
//                 }
//
//                 return GestureDetector(
//                   onTap: () {
//                     if (!hasAnswered) {
//                       setState(() {
//                         selectedIndex = index;
//                         hasAnswered = true;
//                         if (isCorrect) correctAnswers++;
//                       });
//                       countdownTimer?.cancel();
//                     }
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: borderColor, width: 3),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             option,
//                             style: const TextStyle(fontSize: 18),
//                           ),
//                         ),
//                         if (trailingIcon != null) trailingIcon,
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 30),
//             if (hasAnswered)
//               ElevatedButton(
//                 onPressed: goToNextQuestion,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryColor,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text(
//                   'Next',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }