/* import 'package:first_app/core/services/dictonary_service.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/presentation/pages/WordListPage.dart';
import 'package:first_app/presentation/widgets/EditDialog.dart';
import 'package:flutter/material.dart';
import '../../data/models/pf_ing_model.dart';
import '../../data/models/image_model.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Para el reconocimiento de voz
import 'package:logger/logger.dart';
import 'package:first_app/core/services/apiImage.dart';
import '../widgets/Dialog_inform.dart';
import '../widgets/Dialog_Image.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  _Pagina1State createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  final loger = Logger();
  final WordDao wordDao = WordDao();
  final TextEditingController _captWord = TextEditingController();
  //hablar a texto
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<PfIng> _words = [];
  final WordService _wordService = WordService();

  //api para imagenes
  final apiImg = ImageService();
  //paginacion
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // Método para calcular el número de páginas
  int get _pageCount => (_words.length / 3).ceil();

  @override
  void initState() {
    super.initState();
    _loadWords();
    _speech = stt.SpeechToText();
  }

  //funcion para iniciar y detener el texto a voz
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => loger.d('onStatus: $val'),
        onError: (val) => loger.d('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            //_text = val.recognizedWords;
            _captWord.text = val.recognizedWords; //
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _loadWords() async {
    final words = await wordDao.getLastPfIngBasic();
    setState(() {
      _words = words;
    });
  }

  Future<int> _saveWord(Map<String, dynamic> data) async {
    /* String word = _captWord.text;
    if (word.isEmpty) return -1; // Retorna -1 si no hay palabra */

    PfIng newWord = PfIng(
      definition: data['definition'] ?? 'no hay definition',
      word: data['word'] ?? _captWord.text,
      sentence: data['example'] ?? '',
      learn: 0,
      //imageUrl: priImg['url']['regular'],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    //await DatabaseService().insertPfIng(newWord);
    int idWord = await wordDao.insertWord(newWord);
    _captWord.clear();
    _loadWords();
    return idWord;
  }

  Future<Map<String, dynamic>> obtenerDatos(String word) async {
    try {
      final value = await _wordService.getWordDefinition(word);
      loger.d("...............servicio diccionario..............");
      loger.d(value);
      return value;
    } catch (e) {
      loger.d("Error al obtener datos: $e");
      return {
        'definition': 'No se encontró la definición',
        'example': 'No se encontró el ejemplo'
      };
    }
  }

  Future<List<Map<String, dynamic>>> meanings(String word) async {
    try {
      final value = await _wordService.getAllMeanings(word);
      loger.d("...............servicio diccionario..............");
      loger.d(value);
      return value;
    } catch (e) {
      loger.d("Error al obtener significados: $e");
      return [
        {
          'partOfSpeech': 'N/A',
          'definitions': [
            {
              'definition': 'No se encontró la definición',
              'example': 'No se encontró el ejemplo'
            }
          ]
        }
      ];
    }
  }

  Future<List<Map<String, dynamic>>> getImages(String word) async {
    try {
      final value = await apiImg.getMinImg(word);
      loger.d(value[0]);
      return value;
    } catch (e) {
      loger.d("pagina 1, image not found $e");
      return [
        {
          'url': {
            'regular': 'assets/img_defecto.jpg',
            'small': 'assets/img_defecto.jpg',
          }
        }
      ];
    }
  }

  Future<List<int>> saveImages(
      List<Map<String, dynamic>> images, int idWrd) async {
    List<int> savedImages = [];
    if (images.isEmpty) {
      loger.d("No hay imágenes para guardar");
      return savedImages;
    }
    try {
      for (var imag in images) {
        Image_Model img = Image_Model(
          wordId: idWrd, // Asegurarse de que wordId esté presente
          name: imag['description'] ??
              imag['alt_description'] ??
              'Imagen sin nombre',
          author: (imag['user'] is Map)
              ? imag['user']['name']
              : imag['user'] ?? 'Autor desconocido',
          url: imag['url']['regular'],
          tinyurl: imag['url']['small'],
          source: imag['source'] ?? 'Fuente desconocida',
        );
        final savedId = await ImageDao().insertImage(img);
        savedImages.add(savedId);
      }
      return savedImages;
    } catch (e) {
      loger.d("Error al guardar imágenes: $e");
      return [];
    }
  }

  Future<void> _updSenten(int id, String newSentence) async {
    final sentence = newSentence.trim();
    if (sentence.isEmpty) return;

    await wordDao.updateSentence(id, sentence);
    _loadWords();
  }

  void _editSentenceNew(PfIng word) {
    showDialog(
      context: context,
      builder: (context) => EditSentenceDialog(
        initialSentence: word.sentence,
        onUpdate: (newSentence) async {
          await _updSenten(word.id!, newSentence);
          _loadWords(); // Recargar las palabras después de editar
        },
      ),
    );
  }

  Future<void> _deleteWord(int id) async {
    await wordDao.deletePfIng(id);
    _loadWords(); // Recargar las palabras después de eliminar
    // Ajustar la página si es necesario
    if (_currentPage >= _pageCount && _pageCount > 0) {
      setState(() {
        _currentPage = _pageCount - 1;
      });
    }
  }

  void _copySentence(String sentence) {
    Clipboard.setData(ClipboardData(text: sentence));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Texto copiado al portapeles")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprendiendo'),
        actions: [
          ElevatedButton(
            child: const Icon(Icons.navigate_next),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WordListPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Palabra a aprender'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _captWord,
                decoration: InputDecoration(
                  labelText: 'Escribe la palabra',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: _listen,
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final defini = await meanings(_captWord.text);
                final List<Map<String, dynamic>> imgagen =
                    await getImages(_captWord.text);
                int idWord = -1;
                if (defini.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Por favor escribe la palabra a buscar'),
                  ));
                  return;
                }
                //mostrar el dialog
                final Map<String, dynamic>? selectdDefin =
                    await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (_) => DefinitionSelector(
                              meanings: defini,
                            ));
                if (selectdDefin != null) {
                  selectdDefin['word'] = _captWord.text;
                  //pasar al widgets de selector de imagenes para guardar las imagenes realcionadas a word
                  final List<Map<String, dynamic>>? priImg =
                      await showDialog<List<Map<String, dynamic>>>(
                          context: context,
                          builder: (_) => ImageSelectorDialog(
                                imageUrls: imgagen,
                                allowMultipleSelection: false,
                              ));
                  idWord = await _saveWord(selectdDefin);
                  if (idWord != -1 && priImg != null) {
                    //priImg['wordId'] = idWord; // Asignar el ID de la palabra
                    final savedImages = await saveImages(priImg, idWord);
                    loger.d("Imagenes guardadas: $savedImages");
                    if (savedImages.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Palabra guardada con ID: $idWord y ${savedImages.length} imagen(es) guardada(s)'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se guardaron imágenes'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Guardar'),
            ),
            /////////////////////////////////////////////////////
            const SizedBox(height: 10),
            // Widget modificado
            Expanded(
              child: Column(
                children: [
                  // Mostrar solo 3 elementos
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pageCount,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, pageIndex) {
                        final startIndex = pageIndex * 3;
                        final endIndex =
                            (startIndex + 3).clamp(0, _words.length);
                        final displayedWords =
                            _words.sublist(startIndex, endIndex);

                        return ListView.builder(
                          itemCount: displayedWords.length,
                          itemBuilder: (context, index) {
                            final word = displayedWords[index];
                            return ListTile(
                              title: Text(word.word),
                              subtitle: Text(word.sentence),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editSentenceNew(word),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () =>
                                        _copySentence(word.sentence),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteWord(word.id!),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Controles de paginación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                      Text('Página ${_currentPage + 1} de $_pageCount'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _pageCount - 1
                            ? () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */
