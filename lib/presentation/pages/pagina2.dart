import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:flutter/material.dart';
import '../../data/models/pf_ing_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:first_app/presentation/widgets/FlashCardDeck.dart';

class Pagina2 extends StatefulWidget {
  const Pagina2({super.key});

  @override
  _Pagina2State createState() => _Pagina2State();
}

class _Pagina2State extends State<Pagina2> {
  FlutterTts flutterTts = FlutterTts();
  final WordDao wordDao = WordDao();
  late List<PfIng> notLearnedWords = [];
  late List<PfIng> _learnedWords = [];
  final nroRepetitions = 5; //repeticiones para considerar "aprendido"
  int nAprendids = 0;
  int cantPalabs = 0;
  List<PfIng> words = [];
  @override
  void initState() {
    super.initState();
    _initializeWords();
  }

  Future<void> _initializeWords() async {
    await _loadWords();
    _filterWords();
    setState(() {
      nAprendids = _learnedWords.length;
      cantPalabs = words.length;
    });
  }

  Future<void> _loadWords() async {
    final wordss = await wordDao.getAllPfIng();
    setState(() {
      words = wordss;
    });
  }

  // Función para actualizar el estado de aprendizaje de la palabra
  Future<void> _updateLearnStatus(PfIng word, int value) async {
    await wordDao.updatePfIng(word..learn = value);
  }

  void _filterWords() {
    setState(() {
      notLearnedWords =
          words.where((word) => word.learn < nroRepetitions).toList();
      _learnedWords =
          words.where((word) => word.learn >= nroRepetitions).toList();
    });
  }

  //funcione reinicio de aprendizaje
  void resetLearn(PfIng word) {
    setState(() {
      _updateLearnStatus(word, 0);
      _learnedWords.remove(word);
      notLearnedWords.remove(word); //por si acaso
      notLearnedWords.insert(0, word);
      if (_learnedWords.isNotEmpty) {
        nAprendids -= 1;
      }
    });
  }

  void onLearnedTap(PfIng word) {
    _updateLearnStatus(word, word.learn + 1); //actualizar el valor
    setState(() {
      notLearnedWords.remove(word);
      _learnedWords.remove(word); //por si acaso
      if (word.learn < nroRepetitions) {
        notLearnedWords.insert(0, word);
      } else {
        nAprendids += 1;
        _learnedWords.add(word);
      }
    });
  }

  //logica para probar si aprendiste una palabra bien
  void isLearned(PfIng pOrig, String pTest) {
    String origWord = pOrig.word;
    setState(() {
      if (origWord == pTest) {
        //lo pongo en lista de aprendidos
        _updateLearnStatus(pOrig, nroRepetitions); //el valor maximo
        notLearnedWords.remove(pOrig);
        _learnedWords.remove(pOrig);
        _learnedWords.add(pOrig);
        nAprendids += 1;
      } else {
        resetLearn(pOrig);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: isLandscape ? 40.0 : null,
          automaticallyImplyLeading: false,
          title: const SizedBox.shrink(),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(isLandscape ? 8.0 : 25.0),
            child: const TabBar(
              indicatorColor: Colors.blue, // Color de la línea
              indicatorWeight: 2.0, // Grosor de la línea
              labelColor: Colors.transparent, // Hace el texto transparente
              unselectedLabelColor:
                  Colors.transparent, // También para el no seleccionado
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                    icon: Icon(Icons.close,
                        color: Colors.black, size: 17)), // Mantiene el color
                Tab(icon: Icon(Icons.check, color: Colors.green, size: 17)),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                FlashCardDeck(
                    flashCards: notLearnedWords,
                    onLearnedTap: onLearnedTap,
                    resetLearn: resetLearn,
                    isLearned: isLearned),
                FlashCardDeck(
                    flashCards: _learnedWords,
                    onLearnedTap: onLearnedTap,
                    resetLearn: resetLearn,
                    isLearned: isLearned),
              ],
            ),
            // Botón flotante de retroceso
            Positioned(
              top: MediaQuery.of(context).padding.top +
                  8, // Respeta el notch y da un pequeño margen
              left: 8,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                FloatingActionButton(
                  mini: true, // Tamaño más pequeño
                  heroTag: 'backButton', // Necesario si hay otros FABs
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.white, // Color de fondo
                  foregroundColor: Colors.black, // Color del icono
                  elevation: 4.0,
                  child: const Icon(Icons.arrow_back), // Sombra
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent, //color de fondo del contador
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$nAprendids',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey, //color de fondo del contador
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$cantPalabs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
