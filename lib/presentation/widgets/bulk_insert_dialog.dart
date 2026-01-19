// presentation/widgets/modals/bulk_insert_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/domain/entities/word_insertion.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_event.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_state.dart';

class BulkInsertDialog extends StatefulWidget {
  final WordLearningBloc? bloc; // Make it optional

  const BulkInsertDialog({super.key, this.bloc});

  // Helper method to show the dialog
  static Future<void> show(BuildContext context,
      {WordLearningBloc? bloc}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BulkInsertDialog(bloc: bloc),
    );
  }

  @override
  State<BulkInsertDialog> createState() => _BulkInsertDialogState();
}

class _BulkInsertDialogState extends State<BulkInsertDialog> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _wordCount = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _calculateWordCount() {
    final text = _textController.text;
    final lines = text.split('\n');
    final wordCount = lines.where((line) => line.trim().isNotEmpty).length;
    setState(() => _wordCount = wordCount);
  }

  List<WordInsertion> _parseWordsFromText(String text) {
    final lines = text.split('\n');
    final List<WordInsertion> wordInsertions = [];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final parts = trimmedLine.split('|');
      final wordInsertion = WordInsertion(
        word: parts[0].trim(),
        phonetic: parts.length > 1 ? parts[1].trim() : '',
        definition: parts.length > 2 ? parts[2].trim() : '',
        sentence: parts.length > 3 ? parts[3].trim() : '',
      );
      wordInsertions.add(wordInsertion);
    }

    return wordInsertions;
  }

  void _insertWords(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa al menos una palabra');
      return;
    }

    final wordInsertions = _parseWordsFromText(text);
    if (wordInsertions.isEmpty) {
      setState(() => _errorMessage = 'No se encontraron palabras válidas');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get bloc from widget or context
    final bloc = widget.bloc ?? context.read<WordLearningBloc>();
    bloc.add(InsertLotWordsEvent(wordInsertions));
  }

  @override
  Widget build(BuildContext context) {
    // Create the dialog widget
    final dialog = AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.upload_file, size: 24),
          SizedBox(width: 12),
          Text('Inserción Masiva de Palabras'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Formato: palabra|fonética|definición|oración (una por línea)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ejemplo:\napple|ˈæpəl|Una fruta roja|Me como una manzana cada día.',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 10,
              minLines: 6,
              onChanged: (_) => _calculateWordCount(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText:
                    'Escribe aquí...\naprender|əpˈrɛndər|Adquirir conocimiento|Quiero aprender inglés.',
                errorText: _errorMessage,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Palabras detectadas: $_wordCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: _wordCount > 0 ? Colors.green : Colors.grey,
                    fontWeight:
                        _wordCount > 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _insertWords(context),
          icon: const Icon(Icons.save_alt, size: 20),
          label: const Text('Insertar Todas'),
        ),
      ],
    );

    // Wrap with BlocListener
    final listener = BlocListener<WordLearningBloc, WordLearningState>(
      listener: (context, state) {
        if (state is LotWordsInserted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Insertadas ${state.results.length} palabras'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is WordLearningError) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error: ${state.message}';
          });
        }
      },
      child: dialog,
    );

    // If bloc is provided, wrap with BlocProvider
    if (widget.bloc != null) {
      return BlocProvider.value(
        value: widget.bloc!,
        child: listener,
      );
    } else {
      return listener;
    }
  }
}
