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
            // ✅ Título
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),

            // ✅ Total de palabras
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 129, 170, 209),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tienes ${widget.totalWords} palabras',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Text(widget.description,
                    style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 16),
              Container(
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_selectedCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 10),

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
            const SizedBox(height: 14),

            // ✅ Botones de acceso rápido
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (widget.totalWords >= 5) _buildQuickButton(5),
                if (widget.totalWords >= 10) _buildQuickButton(10),
                if (widget.totalWords >= 20) _buildQuickButton(20),
                if (widget.totalWords >= 50) _buildQuickButton(50),
                //_buildQuickButton(widget.totalWords, label: 'Todas'),
              ],
            ),
            const SizedBox(height: 12),

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
