import 'package:flutter/material.dart';
import 'package:first_app/presentation/pages/practice_selection_page.dart';

class PracticeSelectionModal extends StatefulWidget {
  final int totalWords;
  final Function(int count, {int maxAudioPlays}) onStartPractice;
  final PracticeType practiceType;

  const PracticeSelectionModal({
    super.key,
    required this.totalWords,
    required this.onStartPractice,
    required this.practiceType,
  });

  @override
  State<PracticeSelectionModal> createState() => _PracticeSelectionModalState();
}

class _PracticeSelectionModalState extends State<PracticeSelectionModal> {
  late int _selectedCount;
  int _maxAudioPlays = 1;
  double get _totalMax =>
      (widget.totalWords > 30 ? 30.0 : widget.totalWords.toDouble());
  @override
  void initState() {
    super.initState();
    _selectedCount = widget.totalWords < 10 ? widget.totalWords : 10;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                _buildHeader(),
                const SizedBox(height: 20),

                // Total words badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tienes ${widget.totalWords} palabras',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getColor(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Selected count display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getDescription(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getColor(),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_selectedCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Slider
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: _getColor(),
                    thumbColor: _getColor(),
                    overlayColor: _getColor().withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _selectedCount.toDouble(),
                    min: 1,
                    max: _totalMax,
                    divisions: widget.totalWords > 30
                        ? 29 // 30 - 1 = 29 divisiones para 30 valores
                        : (widget.totalWords > 1 ? widget.totalWords - 1 : 1),
                    label: _selectedCount.toString(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCount = value.toInt();
                      });
                    },
                  ),
                ),

                // Min/Max labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$_totalMax',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick selection chips
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (widget.totalWords >= 10) _buildQuickButton(10),
                    if (widget.totalWords >= 15) _buildQuickButton(15),
                    if (widget.totalWords >= 30) _buildQuickButton(30),
                    if (widget.totalWords >= 50) _buildQuickButton(50),
                  ],
                ),
                const SizedBox(height: 24),

                // Audio config (only for spelling)
                if (widget.practiceType == PracticeType.spelling) ...[
                  _buildAudioConfig(),
                  const SizedBox(height: 16),
                ],

                // Practice info
                _buildPracticeInfo(),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: _getColor()),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: _getColor(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onStartPractice(
                            _selectedCount,
                            maxAudioPlays: _maxAudioPlays,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getColor(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Comenzar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getColor().withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIcon(),
            size: 40,
            color: _getColor(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeInfo() {
    final infoPoints = _getInfoPoints();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: _getColor(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Información',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...infoPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getColor(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAudioConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.volume_up, size: 18, color: _getColor()),
            const SizedBox(width: 8),
            Text(
              'Reproducciones de audio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAudioChip(0, 'Sin audio'),
            _buildAudioChip(1, '1 vez'),
            _buildAudioChip(3, '3 veces'),
            _buildAudioChip(-1, 'Ilimitado'),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioChip(int value, String label) {
    final isSelected = _maxAudioPlays == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: _getColor(),
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _maxAudioPlays = value;
          });
        }
      },
    );
  }

  Widget _buildQuickButton(int count) {
    final isSelected = _selectedCount == count;
    return ChoiceChip(
      label: Text('$count'),
      selected: isSelected,
      selectedColor: _getColor(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCount = count;
          });
        }
      },
    );
  }

  String _getTitle() {
    switch (widget.practiceType) {
      case PracticeType.flashcard:
        return 'Flashcards';
      case PracticeType.sentence:
        return 'Ordenar Oraciones';
      case PracticeType.spelling:
        return 'Spelling';
      case PracticeType.listening:
        return 'Listening';
      case PracticeType.matching:
        return 'Emparejar';
      case PracticeType.matchingDefinition:
        return 'Emparejar-Definicion';
    }
  }

  String _getDescription() {
    switch (widget.practiceType) {
      case PracticeType.flashcard:
        return '¿Cuántas palabras practicar?';
      case PracticeType.sentence:
        return '¿Cuántas oraciones ordenar?';
      case PracticeType.spelling:
        return '¿Cuántas palabras escribir?';
      case PracticeType.listening:
        return '¿Cuántas palabras escuchar?';
      case PracticeType.matching:
        return '¿Cuántas palabras emparejar?';
      case PracticeType.matchingDefinition:
        return '¿Cuántas palabras emparejar?';
    }
  }

  IconData _getIcon() {
    switch (widget.practiceType) {
      case PracticeType.flashcard:
        return Icons.style;
      case PracticeType.sentence:
        return Icons.sort;
      case PracticeType.spelling:
        return Icons.keyboard;
      case PracticeType.listening:
        return Icons.headphones;
      case PracticeType.matching:
        return Icons.compare_arrows;
      case PracticeType.matchingDefinition:
        return Icons.menu_book;
    }
  }

  Color _getColor() {
    switch (widget.practiceType) {
      case PracticeType.flashcard:
        return Colors.blue;
      case PracticeType.sentence:
        return Colors.green;
      case PracticeType.spelling:
        return Colors.orange;
      case PracticeType.listening:
        return Colors.purple;
      case PracticeType.matching:
        return Colors.teal;
      case PracticeType.matchingDefinition:
        return Colors.amber;
    }
  }

  List<String> _getInfoPoints() {
    switch (widget.practiceType) {
      case PracticeType.flashcard:
        return [
          'Verás palabras con definiciones',
          'Puedes ver imágenes de referencia',
          'Marca si conoces cada palabra',
        ];
      case PracticeType.sentence:
        return [
          'Palabras desordenadas',
          'Forma oraciones correctas',
          'Arrastra al orden correcto',
        ];
      case PracticeType.spelling:
        return [
          'Ve la definición de cada palabra',
          'Escribe la palabra correcta en inglés',
          'Activa el audio si lo necesitas',
        ];
      case PracticeType.listening:
        return [
          'Escucha con atención',
          'Identifica las palabras',
          'Mejora tu comprensión',
        ];
      case PracticeType.matching:
        return [
          'Relaciona cada palabra con su traducción',
          'Selecciona un tile de cada columna',
          'Recibirás feedback visual inmediato',
        ];
      case PracticeType.matchingDefinition:
        return [
          'Relaciona cada palabra con su definición',
          'Selecciona un tile de cada columna',
          'Recibirás feedback visual inmediato',
        ];
    }
  }
}
