import 'package:flutter/material.dart';

class DefinitionSelector extends StatefulWidget {
  final List<Map<String, dynamic>> meanings;

  const DefinitionSelector({super.key, required this.meanings});

  @override
  _DefinitionSelectorState createState() => _DefinitionSelectorState();
}

class _DefinitionSelectorState extends State<DefinitionSelector> {
  int _selectedMeaningIndex = 0;
  int? _selectedDefinitionIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.meanings.isEmpty) {
      return const Center(child: Text('No hay definitiones disponibles'));
    }

    final selectedMeaning = widget.meanings[_selectedMeaningIndex];
    final definitions = selectedMeaning['definitions'] as List<dynamic>;
    final partOfSpeech = selectedMeaning['partOfSpeech'] as String;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Seleccionar Definición',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),

              // Selector de Part of Speech
              DropdownButtonFormField<int>(
                value: _selectedMeaningIndex,
                decoration: const InputDecoration(
                  labelText: 'Cat. Gramatical',
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

              const SizedBox(height: 5),

              // Lista de definitiones con tamaño fijo
              const Text(
                'definitiones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: definitions.length,
                  itemBuilder: (context, index) {
                    final definition =
                        definitions[index] as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: _selectedDefinitionIndex == index
                          ? Colors.blue[50]
                          : null,
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
                                '${index + 1}. ${definition['definition']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (definition['example'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Ejemplo: ${definition['example']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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

              const SizedBox(height: 16),

// Reemplazando tu Row:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final bool esPequeno = screenWidth < 400;

                      // Si el diálogo es muy pequeño, la Row también lo será
                      if (constraints.maxWidth < 180) {
                        // Un umbral más bajo para solo iconos
                        // Botón Cancelar (solo Icono)
                        return TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        );
                      }

                      // Diseño responsivo basado en LayoutBuilder:

                      return Row(
                        mainAxisSize: MainAxisSize
                            .min, // Importante para que la Row se ajuste al contenido
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
                                      'partOfSpeech': partOfSpeech,

                                      'definition': selectedDef['definition'],

                                      'example': selectedDef['example'],

                                      'synonyms': selectedDef['synonyms'] ??
                                          [], // Lista de sinónimos

                                      'antonyms': selectedDef['antonyms'] ?? [],
                                    });
                                  }
                                : null,
                            child: esPequeno
                                ? const Icon(Icons.arrow_forward)
                                : const Text('Siguiente'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
