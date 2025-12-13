import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CombinedWordDialog extends StatefulWidget {
  final String word;
  final List<Map<String, dynamic>> meanings;
  final List<Map<String, dynamic>> images;

  const CombinedWordDialog({
    super.key,
    required this.word,
    required this.meanings,
    required this.images,
  });

  @override
  State<CombinedWordDialog> createState() => _CombinedWordDialogState();
}

class _CombinedWordDialogState extends State<CombinedWordDialog> {
  int _currentStep = 0;
  int _selectedMeaningIndex = 0;
  int? _selectedDefinitionIndex;
  bool _multipleSelection = false;

  // CAMBIO CRÍTICO: Guardar índices en lugar de objetos completos
  final Set<int> _selectedImageIndices = {};

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
      insetPadding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, dialogConstraints) {
          final bool esPequeno = dialogConstraints.maxWidth < 400;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              minWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  if (_currentStep == 0) ...[
                    _buildDefinitionStep(definitions, esPequeno),
                  ] else ...[
                    _buildImageStep(esPequeno),
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
          const Text(
            'Selecciona una definición:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            Text(
                              definition['definition'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (definition['example'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Ej: "${definition['example']}"',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
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

  Widget _buildImageStep(bool esPequeno) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Selecciona imagen(es):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _multipleSelection,
                onChanged: (value) {
                  setState(() {
                    _multipleSelection = value;
                    // Si desactiva múltiple, mantener solo la primera
                    if (!value && _selectedImageIndices.length > 1) {
                      final first = _selectedImageIndices.first;
                      _selectedImageIndices.clear();
                      _selectedImageIndices.add(first);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Contador de imágenes seleccionadas
          if (_selectedImageIndices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  Text(
                    '${_selectedImageIndices.length} imagen(es) seleccionada(s)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          if (widget.images.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay imágenes disponibles',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puedes continuar sin imagen',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    // CAMBIO CRÍTICO: Usar el índice para comparar
                    final isSelected = _selectedImageIndices.contains(index);
                    final imageData = widget.images[index];
                    final imageUrl = imageData['url']['thumb'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          Logger().i(
                              'Tap en imagen index: $index, isSelected: $isSelected');

                          if (_multipleSelection) {
                            // Modo múltiple
                            if (isSelected) {
                              _selectedImageIndices.remove(index);
                            } else {
                              _selectedImageIndices.add(index);
                            }
                          } else {
                            // Modo simple
                            if (isSelected) {
                              _selectedImageIndices.clear();
                            } else {
                              _selectedImageIndices.clear();
                              _selectedImageIndices.add(index);
                            }
                          }

                          Logger().i(
                              'Índices seleccionados: $_selectedImageIndices');
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            // Número de orden
                            if (isSelected &&
                                _multipleSelection &&
                                _selectedImageIndices.length > 1)
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${_selectedImageIndices.toList().indexOf(index) + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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

  Widget _buildActionButtons(
    List<dynamic> definitions,
    String partOfSpeech,
    bool esPequeno,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.95),
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep == 1)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
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
                onPressed: () => Navigator.pop(context),
                child: esPequeno
                    ? const Icon(Icons.close)
                    : const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              if (_currentStep == 0)
                ElevatedButton.icon(
                  onPressed: _selectedDefinitionIndex != null
                      ? () {
                          setState(() {
                            _currentStep = 1;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: esPequeno
                      ? const SizedBox.shrink()
                      : const Text('Siguiente'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    final selectedDef = definitions[_selectedDefinitionIndex!];

                    // CAMBIO CRÍTICO: Convertir índices a objetos
                    final selectedImages = _selectedImageIndices
                        .map((index) => widget.images[index])
                        .toList();

                    Logger().i('Índices seleccionados: $_selectedImageIndices');
                    Logger().i('Imágenes seleccionadas: $selectedImages');

                    Navigator.pop(context, {
                      'word': widget.word,
                      'partOfSpeech': partOfSpeech,
                      'definition': selectedDef['definition'],
                      'example': selectedDef['example'],
                      'synonyms': selectedDef['synonyms'] ?? [],
                      'antonyms': selectedDef['antonyms'] ?? [],
                      'images': selectedImages,
                    });
                  },
                  icon: const Icon(Icons.save, size: 18),
                  label: esPequeno
                      ? const SizedBox.shrink()
                      : const Text('Guardar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
