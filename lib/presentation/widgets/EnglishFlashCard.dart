import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:logger/logger.dart';
import 'package:first_app/data/models/image_model.dart';

class EnglishFlashCard extends StatefulWidget {
  //propiedades para personalizar el widget
  final PfIng wordData;
  final List<Image_Model> imgsData; // Lista de imágenes relacionadas
  final String word;
  final int learn;
  final Color cardColor;
  final Color textColor;
  final double borderRadius;
  final bool showFrontByDefault;
  final VoidCallback onLearned;
  final VoidCallback resetLearn;
  final Function(String) testingWord;
  const EnglishFlashCard({
    super.key,
    required this.wordData,
    required this.word,
    required this.learn,
    required this.onLearned,
    required this.resetLearn,
    required this.testingWord,
    required this.imgsData,
    this.cardColor = Colors.white,
    this.textColor = Colors.black,
    this.borderRadius = 15.0,
    this.showFrontByDefault = true,
  });

  @override
  State<EnglishFlashCard> createState() => _EnglishFlasCardState();
}

class _EnglishFlasCardState extends State<EnglishFlashCard> {
  final Logger log = Logger();
  late bool _showFront;
  late PfIng _word;
  FlutterTts flutterTts = FlutterTts();
  late final TextEditingController _wordTest;
  @override
  void initState() {
    super.initState();
    _showFront = widget.showFrontByDefault;
    _word = widget.wordData;
    _wordTest = TextEditingController();
  }

  Future<void> speakf(String text) async {
    try {
      await flutterTts.setLanguage('en-US');
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(text);
    } catch (e) {
      log.d('Error al leer el texto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFront = !_showFront;
        });
      },
      child: Card(
        elevation: 5.0,
        margin: EdgeInsets.all(isPortrait ? 8.0 : 4.0), //nose que cambia
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        color: widget.cardColor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _showFront ? _buildFrontSide() : _buildBackSide(),
        ),
      ),
    );
  }

  Widget _buildFrontSide() {
    //debugPrint('URL de la imagen: ${widget.imgsData.isNotEmpty ? widget.imgsData[0].url : 'No image available'}');
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        key: const ValueKey<String>('front'),
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight,
          maxWidth: constraints.maxWidth,
        ),
        padding: EdgeInsets.all(constraints.maxHeight * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //imagen de la palabra
            SizedBox(
              height: constraints.maxHeight * 0.5,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Stack(fit: StackFit.expand, children: [
                  //Imagen principal
                  Image.network(
                    widget.imgsData.isNotEmpty && widget.imgsData[0].url != null
                        ? widget.imgsData[0].url!
                        : "assets/img_defecto.jpg", // no esta definido en el modelo
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: constraints.maxHeight * 0.1,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  //icono de autor en la esquina superio derecha
                  //if(_word.autor != null && _word.autor!.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Autor: ${widget.imgsData[0].author} \nfuente: nombre de fuente'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_rounded,
                            size: 18,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 2),
            //Palabra en ingles
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _word.word.isNotEmpty == true ? _word.word : 'Word not found',
                  style: TextStyle(
                    fontSize: constraints.maxHeight * 0.1,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 5),
            //Instruccion para voltear
            Text(
              'Tap to see definition',
              style: TextStyle(
                fontSize: constraints.maxHeight * 0.02,
                fontStyle: FontStyle.italic,
                color: widget.textColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            //botones de control
            SizedBox(
                height: constraints.maxHeight * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        widget
                            .onLearned(); //llamo funcion incremento en pagina 2
                      },
                      icon:
                          Icon(Icons.check, size: constraints.maxHeight * 0.04),
                      label: Text(
                        'Learned',
                        style:
                            TextStyle(fontSize: constraints.maxHeight * 0.03),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget
                            .resetLearn(); //llamo la funcion reset en pagina 2
                      },
                      icon: Icon(Icons.restart_alt,
                          size: constraints.maxHeight * 0.04),
                      label: Text(
                        "Again",
                        style:
                            TextStyle(fontSize: constraints.maxHeight * 0.03),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                )),
          ],
        ),
      );
    });
  }

  Widget _buildBackSide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          key: const ValueKey<String>('back'),
          padding: EdgeInsets.all(constraints.maxHeight * 0.02),
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(constraints.maxHeight * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Test de aprendizaje
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextField(
                          controller: _wordTest,
                          decoration: InputDecoration(
                            labelText: 'Aprendiste?',
                            border: const OutlineInputBorder(),
                            isDense: true, // Reduce altura interna
                            contentPadding:
                                EdgeInsets.all(constraints.maxHeight * 0.015),
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.02),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () => widget.testingWord(_wordTest.text),
                          style: ElevatedButton.styleFrom(
                            padding:
                                EdgeInsets.all(constraints.maxHeight * 0.015),
                          ),
                          child: Icon(
                            Icons.send,
                            size: constraints.maxHeight * 0.04,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: constraints.maxHeight * 0.02),

                  // Definición
                  _buildDefinitionSection(
                    constraints,
                    _word.definition,
                    () => speakf(_word.definition),
                  ),

                  SizedBox(height: constraints.maxHeight * 0.02),

                  // Ejemplo
                  _buildExampleSection(
                    constraints,
                    _word.sentence,
                    () => speakf(_word.sentence),
                  ),

                  SizedBox(height: constraints.maxHeight * 0.04),

                  // Instrucción para voltear
                  Text(
                    'Tap to see word again',
                    style: TextStyle(
                      fontSize: constraints.maxHeight * 0.022,
                      fontStyle: FontStyle.italic,
                      color: widget.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefinitionSection(
    BoxConstraints constraints,
    String definition,
    VoidCallback onSpeak,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Definition:',
              style: TextStyle(
                fontSize:
                    constraints.maxHeight * 0.04, // ~18px en altura estándar
                fontWeight: FontWeight.bold,
                color: widget.textColor,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.volume_up,
                size: constraints.maxHeight * 0.05,
              ),
              onPressed: onSpeak,
            ),
          ],
        ),
        SizedBox(height: constraints.maxHeight * 0.005),
        Text(
          definition,
          style: TextStyle(
            fontSize: constraints.maxHeight * 0.04, // ~16px
            color: widget.textColor,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildExampleSection(
    BoxConstraints constraints,
    String example,
    VoidCallback onSpeak,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Example:',
              style: TextStyle(
                fontSize: constraints.maxHeight * 0.04, // ~18px
                fontWeight: FontWeight.bold,
                color: widget.textColor,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.volume_up,
                size: constraints.maxHeight * 0.05,
              ),
              onPressed: onSpeak,
            ),
          ],
        ),
        SizedBox(height: constraints.maxHeight * 0.005),
        Text(
          '"$example"',
          style: TextStyle(
            fontSize: constraints.maxHeight * 0.04, // ~16px
            fontStyle: FontStyle.italic,
            color: widget.textColor,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
