import 'package:flutter/material.dart';

class PracticeSelectionModal extends StatefulWidget {
  final int totalWords;
  final Function(int) onStartPractice;
  final String title; // ✅ Nuevo parámetro
  final String description;
  const PracticeSelectionModal({
    required this.totalWords,
    required this.onStartPractice,
    this.title = 'Modo Práctica', // ✅ Valor por defecto
    this.description = '¿Cuántas quieres practicar?',
  });

  @override
  State<PracticeSelectionModal> createState() => _PracticeSelectionModalState();
}

class _PracticeSelectionModalState extends State<PracticeSelectionModal> {
  late int _selectedCount;

  @override
  void initState() {
    super.initState();
    // Valor inicial: 5 o el total si hay menos
    _selectedCount = widget.totalWords < 5 ? widget.totalWords : 5;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Ícono
            const Icon(
              Icons.school,
              size: 60,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),

            // ✅ Título
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Total de palabras
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Tienes ${widget.totalWords} palabras',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(widget.description,
                style: const TextStyle(fontSize: 16)), // ✅ Usar parámetr
            const SizedBox(height: 16),
            // ✅ Número seleccionado (grande)
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$_selectedCount',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Slider
            Slider(
              value: _selectedCount.toDouble(),
              min: 1,
              max: widget.totalWords.toDouble(),
              divisions: widget.totalWords > 1 ? widget.totalWords - 1 : 1,
              label: _selectedCount.toString(),
              activeColor: Colors.deepPurple,
              onChanged: (value) {
                setState(() {
                  _selectedCount = value.toInt();
                });
              },
            ),

            // ✅ Etiquetas min/max
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
                    ),
                  ),
                  Text(
                    '${widget.totalWords}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Botones de acceso rápido
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (widget.totalWords >= 5) _buildQuickButton(5),
                if (widget.totalWords >= 10) _buildQuickButton(10),
                if (widget.totalWords >= 20) _buildQuickButton(20),
                if (widget.totalWords >= 50) _buildQuickButton(50),
                _buildQuickButton(widget.totalWords, label: 'Todas'),
              ],
            ),
            const SizedBox(height: 24),

            // ✅ Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onStartPractice(_selectedCount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(int count, {String? label}) {
    final isSelected = _selectedCount == count;
    return ChoiceChip(
      label: Text(label ?? '$count'),
      selected: isSelected,
      selectedColor: Colors.deepPurple,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
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
}
