import 'package:flutter/material.dart';

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
  int _selectedMeaningIndex = 0;
  int? _selectedDefinitionIndex;
  String? _selectedImageUrl;

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
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nueva palabra: ${widget.word}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),

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

                  // Definitions Section
                  const Text(
                    'Definiciones:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: definitions.length,
                        itemBuilder: (context, index) {
                          final definition =
                              definitions[index] as Map<String, dynamic>;
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
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                        if (isSelected)
                                          const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${index + 1}. ${definition['definition']}',
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          left: 28,
                                        ),
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

                  const SizedBox(height: 16),

                  // Images Section
                  if (widget.images.isNotEmpty) ...[
                    const Text(
                      'Seleccionar imagen (opcional):',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: esPequeno ? 2 : 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: widget.images.length,
                          itemBuilder: (context, index) {
                            final image = widget.images[index];
                            final imageUrl =
                                image['url']['thumb'] ?? image['thumb'];
                            final isSelected = _selectedImageUrl == imageUrl;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImageUrl =
                                      isSelected ? null : imageUrl;
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
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: esPequeno
                            ? const Icon(Icons.close)
                            : const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _selectedDefinitionIndex != null
                            ? () {
                                final selectedDef =
                                    definitions[_selectedDefinitionIndex!];

                                Navigator.pop(context, {
                                  'word': widget.word,
                                  'partOfSpeech': partOfSpeech,
                                  'definition': selectedDef['definition'],
                                  'example': selectedDef['example'],
                                  'synonyms': selectedDef['synonyms'] ?? [],
                                  'antonyms': selectedDef['antonyms'] ?? [],
                                  'imageUrl': _selectedImageUrl,
                                });
                              }
                            : null,
                        child: esPequeno
                            ? const Icon(Icons.save)
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
