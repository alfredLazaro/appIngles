// presentation/widgets/modals/translation_bulk_insert_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/data/datasources/local/db_constants.dart';
import 'package:first_app/presentation/bloc/translation/translation_bloc.dart';
import 'package:first_app/presentation/bloc/translation/translation_event.dart';
import 'package:first_app/presentation/bloc/translation/translation_state.dart';

class TranslationBulkInsertDialog extends StatefulWidget {
  final int wordId;
  final String wordText; // To show which word we're adding translations for
  final TranslationBloc? bloc; // Make it optional

  const TranslationBulkInsertDialog({
    super.key,
    required this.wordId,
    required this.wordText,
    this.bloc,
  });

  // Helper method to show the dialog
  static Future<void> show(
    BuildContext context, {
    required int wordId,
    required String wordText,
    TranslationBloc? bloc,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TranslationBulkInsertDialog(
        wordId: wordId,
        wordText: wordText,
        bloc: bloc,
      ),
    );
  }

  @override
  State<TranslationBulkInsertDialog> createState() =>
      _TranslationBulkInsertDialogState();
}

class _TranslationBulkInsertDialogState
    extends State<TranslationBulkInsertDialog> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _translationCount = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _calculateTranslationCount() {
    final text = _textController.text;
    final lines = text.split('\n');
    final count = lines.where((line) => line.trim().isNotEmpty).length;
    setState(() => _translationCount = count);
  }

  List<Map<String, dynamic>> _parseTranslationsFromText(String text) {
    final lines = text.split('\n');
    final List<Map<String, dynamic>> translations = [];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Format: translation|alternative1,alternative2,alternative3
      // Or just: translation
      final parts = trimmedLine.split('|');
      
      final wordTranslate = parts[0].trim();
      final alternatives = parts.length > 1 
          ? parts[1].trim()
          : '';

      translations.add({
        TranslationFields.wordTranslate: wordTranslate,
        TranslationFields.alternatives: alternatives,
      });
    }

    return translations;
  }

  void _insertTranslations(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa al menos una traducción';
      });
      return;
    }

    final translations = _parseTranslationsFromText(text);
    if (translations.isEmpty) {
      setState(() {
        _errorMessage = 'No se encontraron traducciones válidas';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get bloc from widget or context
    final bloc = widget.bloc ?? context.read<TranslationBloc>();
    bloc.add(AddBulkTranslationsEvent(
      wordId: widget.wordId,
      translations: translations,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Create the dialog widget
    final dialog = AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.translate, size: 24),
              const SizedBox(width: 12),
              const Text('Agregar Traducciones'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Palabra: "${widget.wordText}"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Formato: traducción|alternativa1,alternativa2',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ejemplo:\nmanzana|fruta roja,poma\naprender|estudiar,adquirir conocimiento',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 10,
              minLines: 6,
              onChanged: (_) => _calculateTranslationCount(),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Escribe aquí...\nmanzana\npera|fruta amarilla',
                errorText: _errorMessage,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Traducciones detectadas: $_translationCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: _translationCount > 0 ? Colors.green : Colors.grey,
                    fontWeight: _translationCount > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
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
          onPressed: _isLoading ? null : () => _insertTranslations(context),
          icon: const Icon(Icons.save_alt, size: 20),
          label: const Text('Insertar Todas'),
        ),
      ],
    );

    // Wrap with BlocListener
    final listener = BlocListener<TranslationBloc, TranslationState>(
      listener: (context, state) {
        if (state is TranslationsBulkAdded) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Insertadas ${state.translations.length} traducciones',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is TranslationError) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error: ${state.message}';
          });
        } else if (state is TranslationLoading) {
          setState(() {
            _isLoading = true;
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

// ============================================================================
// Alternative: Simpler inline widget (for embedding in a page)
// ============================================================================

class TranslationBulkInsertWidget extends StatefulWidget {
  final int wordId;
  final String wordText;
  final VoidCallback? onSuccess;

  const TranslationBulkInsertWidget({
    super.key,
    required this.wordId,
    required this.wordText,
    this.onSuccess,
  });

  @override
  State<TranslationBulkInsertWidget> createState() =>
      _TranslationBulkInsertWidgetState();
}

class _TranslationBulkInsertWidgetState
    extends State<TranslationBulkInsertWidget> {
  final TextEditingController _textController = TextEditingController();
  bool _isExpanded = false;
  int _translationCount = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _calculateTranslationCount() {
    final text = _textController.text;
    final lines = text.split('\n');
    final count = lines.where((line) => line.trim().isNotEmpty).length;
    setState(() => _translationCount = count);
  }

  List<Map<String, dynamic>> _parseTranslationsFromText(String text) {
    final lines = text.split('\n');
    final List<Map<String, dynamic>> translations = [];

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final parts = trimmedLine.split('|');
      final wordTranslate = parts[0].trim();
      final alternatives = parts.length > 1 ? parts[1].trim() : '';

      translations.add({
        TranslationFields.wordTranslate: wordTranslate,
        TranslationFields.alternatives: alternatives,
      });
    }

    return translations;
  }

  void _insertTranslations(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa al menos una traducción'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final translations = _parseTranslationsFromText(text);
    if (translations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontraron traducciones válidas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<TranslationBloc>().add(AddBulkTranslationsEvent(
          wordId: widget.wordId,
          translations: translations,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationBloc, TranslationState>(
      listener: (context, state) {
        if (state is TranslationsBulkAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Insertadas ${state.translations.length} traducciones',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _textController.clear();
          setState(() {
            _translationCount = 0;
            _isExpanded = false;
          });
          widget.onSuccess?.call();
        } else if (state is TranslationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(16),
        child: ExpansionPanelList(
          elevation: 1,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              _isExpanded = !isExpanded;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return ListTile(
                  leading: const Icon(Icons.translate),
                  title: const Text('Agregar traducciones masivas'),
                  subtitle: Text('Palabra: "${widget.wordText}"'),
                );
              },
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Formato: traducción|alternativa1,alternativa2',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 6,
                      onChanged: (_) => _calculateTranslationCount(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'manzana|fruta roja\npera',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detectadas: $_translationCount',
                          style: TextStyle(
                            color: _translationCount > 0
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: _translationCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _insertTranslations(context),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Insertar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              isExpanded: _isExpanded,
            ),
          ],
        ),
      ),
    );
  }
}