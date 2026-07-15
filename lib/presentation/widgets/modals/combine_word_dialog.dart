import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/presentation/widgets/image_selection_grid.dart';
import 'package:logger/logger.dart';

class CombinedWordDialog extends StatefulWidget {
  final String word;
  final List<Map<String, dynamic>> meanings;
  final List<ImageSearchResult> images;
  final Map<String, dynamic>? translation;

  const CombinedWordDialog({
    super.key,
    required this.word,
    required this.meanings,
    required this.images,
    this.translation,
  });

  @override
  State<CombinedWordDialog> createState() => _CombinedWordDialogState();
}

class _CombinedWordDialogState extends State<CombinedWordDialog> {
  int _currentStep = 0;
  int _selectedMeaningIndex = 0;
  int? _selectedDefinitionIndex;
  final List<ImageSearchResult> _selectedImageUrls = [];

  @override
  Widget build(BuildContext context) {
    if (widget.meanings.isEmpty) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('No hay definiciones disponibles'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }

    final selectedMeaning = widget.meanings[_selectedMeaningIndex];
    final definitions = selectedMeaning['definitions'] as List<dynamic>;
    final partOfSpeech = selectedMeaning['partOfSpeech'] as String;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppLayout.dialogInset),
      child: LayoutBuilder(
        builder: (context, dialogConstraints) {
          final bool esPequeno = dialogConstraints.maxWidth < 400;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * AppLayout.dialogMaxHeightRatio,
              minWidth: MediaQuery.of(context).size.width * AppLayout.dialogMinWidthRatio,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 3,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),

                  if (_currentStep == 0) ...[
                    _buildDefinitionStep(definitions, esPequeno),
                  ] else if (_currentStep == 1) ...[
                    Expanded(
                      child: ImageSelectionGrid(
                        images: widget.images,
                        onSelectionChanged: (selected) {
                          _selectedImageUrls.clear();
                          _selectedImageUrls.addAll(selected);
                        },
                      ),
                    ),
                  ] else ...[
                    _buildTranslationStep(esPequeno),
                  ],

                  const SizedBox(height: 16),

                  _buildActionButtons(definitions, partOfSpeech, esPequeno),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefinitionStep(List<dynamic> definitions, bool esPequeno) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: _selectedMeaningIndex,
            decoration: const InputDecoration(
              labelText: 'Categoría Gramatical',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: List.generate(widget.meanings.length, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Text(widget.meanings[index]['partOfSpeech']),
              );
            }),
            onChanged: (int? newIndex) {
              setState(() {
                _selectedMeaningIndex = newIndex!;
                _selectedDefinitionIndex = null;
              });
            },
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: definitions.length,
                itemBuilder: (context, index) {
                  final definition = definitions[index] as Map<String, dynamic>;
                  final isSelected = _selectedDefinitionIndex == index;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    color: isSelected ? Colors.blue[50] : null,
                    elevation: isSelected ? 2 : 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDefinitionIndex = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${definition['definition']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (definition['example'] != null)
                              Text(
                                'Ej: "${definition['example']}"',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationStep(bool esPequeno) {
    final translation = widget.translation;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Traducción al español',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (translation == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 48, color: Colors.orange),
                    const SizedBox(height: 12),
                    const Text(
                      'Traducción no disponible',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'La API de traducción no respondió.\nPuedes guardar la palabra igualmente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.word,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            translation['translatedText'] ?? '',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (translation['alternatives'] != null &&
                        (translation['alternatives'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Alternativas:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children:
                                  (translation['alternatives'] as List)
                                      .map((alt) => Chip(
                                            label: Text('$alt'),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                          ))
                                      .toList(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    List<dynamic> definitions,
    String partOfSpeech,
    bool esPequeno,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _currentStep--;
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: esPequeno ? const SizedBox.shrink() : const Text('Atrás'),
          )
        else
          const SizedBox.shrink(),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Navigator.pop(context),
              child:
                  esPequeno ? const Icon(Icons.close) : const Text('Cancelar'),
            ),
            const SizedBox(width: 8),

            if (_currentStep < 2)
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 32),
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: (_currentStep == 0 && _selectedDefinitionIndex == null)
                    ? null
                    : () {
                        setState(() {
                          _currentStep++;
                        });
                      },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: esPequeno
                    ? const SizedBox.shrink()
                    : const Text('Siguiente'),
              )
            else
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 32),
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  final selectedDef = definitions[_selectedDefinitionIndex!];
                  Logger().i('Imagenes seleccionadas: $_selectedImageUrls');
                  Navigator.pop(context, {
                    'word': widget.word,
                    'partOfSpeech': partOfSpeech,
                    'definition': selectedDef['definition'],
                    'example': selectedDef['example'],
                    'phonetic': selectedDef['phonetic'],
                    'synonyms': selectedDef['synonyms'] ?? [],
                    'antonyms': selectedDef['antonyms'] ?? [],
                    'images': _selectedImageUrls,
                    'translation': widget.translation,
                  });
                },
                icon: const Icon(Icons.save, size: 18),
                label:
                    esPequeno ? const SizedBox.shrink() : const Text('Guardar'),
              ),
          ],
        ),
      ],
    );
  }
}
