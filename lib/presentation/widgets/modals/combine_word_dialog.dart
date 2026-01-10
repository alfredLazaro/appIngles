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
  int _currentStep = 0; // 0 = definiciones, 1 = imágenes
  int _selectedMeaningIndex = 0;
  int? _selectedDefinitionIndex;
  bool _multipleSelection = false; // Toggle para selección múltiple
  final List<Map<String, dynamic>> _selectedImageUrls =
      []; // Set para múltiples imágenes

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
                  // Indicador de progreso
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 2,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),

                  // Contenido según el paso actual
                  if (_currentStep == 0) ...[
                    _buildDefinitionStep(
                      definitions,
                      esPequeno,
                    ),
                  ] else ...[
                    _buildImageStep(esPequeno),
                  ],

                  const SizedBox(height: 16),

                  // Botones de acción
                  _buildActionButtons(
                    definitions,
                    partOfSpeech,
                    esPequeno,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefinitionStep(
    List<dynamic> definitions,
    bool esPequeno,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Part of Speech Selector
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

  Widget _buildImageStep(bool esPequeno) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'imagenes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: MediaQuery.of(context).size.width < 400 ? 0.8 : 1.0,
                child: Switch(
                  value: _multipleSelection,
                  onChanged: (value) {
                    setState(() {
                      _multipleSelection = value;
                      // Si desactiva múltiple, mantener solo la primera seleccionada
                      if (!value && _selectedImageUrls.length > 1) {
                        final first = _selectedImageUrls.first;
                        _selectedImageUrls.clear();
                        _selectedImageUrls.add(first);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.images.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay imágenes disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Puedes continuar sin imagen',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: widget.images.length,
                        itemBuilder: (context, index) {
                          final imageUrl = widget.images[index];
                          final isSelected =
                              _selectedImageUrls.contains(imageUrl);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_multipleSelection) {
                                  // Modo múltiple: agregar/quitar de la lista
                                  if (isSelected) {
                                    _selectedImageUrls.remove(imageUrl);
                                  } else {
                                    _selectedImageUrls.add(imageUrl);
                                  }
                                } else {
                                  // Modo simple: solo una imagen
                                  if (isSelected) {
                                    _selectedImageUrls.clear();
                                  } else {
                                    _selectedImageUrls.clear();
                                    _selectedImageUrls.add(imageUrl);
                                  }
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade300,
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
                                      imageUrl['url']['thumb'] ?? '',
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
                                  // Número de orden en selección múltiple
                                  if (isSelected &&
                                      _multipleSelection &&
                                      _selectedImageUrls.length > 1)
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
                                          '${_selectedImageUrls.toList().indexOf(imageUrl) + 1}',
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
        // Botón atrás (solo en paso 2)
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

        // Botones de la derecha
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4), // menos alto
                minimumSize: const Size(0, 32), // altura mínima reducida
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // quita espacio extra
              ),
              onPressed: () => Navigator.pop(context),
              child:
                  esPequeno ? const Icon(Icons.close) : const Text('Cancelar'),
            ),
            const SizedBox(width: 8),

            // Botón Siguiente o Guardar
            if (_currentStep == 0)
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // menos alto
                  minimumSize: const Size(0, 32), // altura mínima reducida
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // quita espacio extra
                ),
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
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // menos alto
                  minimumSize: const Size(0, 32), // altura mínima reducida
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // quita espacio extra
                ),
                onPressed: () {
                  final selectedDef = definitions[_selectedDefinitionIndex!];
                  //String phonethics = definitions['phonethic']; //debo actualizar esto
                  // Convertir las URLs seleccionadas a List<Map<String, dynamic>>
                  Logger().i('Imagenes seleccionadas: $_selectedImageUrls');
                  Navigator.pop(context, {
                    'word': widget.word,
                    'partOfSpeech': partOfSpeech,
                    'definition': selectedDef['definition'],
                    'example': selectedDef['example'],
                    'synonyms': selectedDef['synonyms'] ?? [],
                    'antonyms': selectedDef['antonyms'] ?? [],
                    'images':
                        _selectedImageUrls, // Ahora es List<Map<String, dynamic>>
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
