import 'package:first_app/presentation/bloc/translation/translation_bloc.dart';
import 'package:first_app/presentation/bloc/translation/translation_event.dart';
import 'package:first_app/presentation/bloc/translation/translation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';

class TranslationTextInputWidget extends StatefulWidget {
  final int word_id;
  final VoidCallback? onTranslationsAdded;
  final bool showExamples;

  const TranslationTextInputWidget({
    super.key,
    required this.word_id,
    this.onTranslationsAdded,
    this.showExamples = true,
  });

  @override
  State<TranslationTextInputWidget> createState() =>
      _TranslationTextInputWidgetState();
}

class _TranslationTextInputWidgetState
    extends State<TranslationTextInputWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TranslationBloc, TranslationState>(
      listener: (context, state) {
        if (state is TranslationLoading) {
          setState(() => _isLoading = true);
        } else if (state is TranslationsBulkAdded) {
          setState(() => _isLoading = false);
          _textController.clear();
          _focusNode.unfocus();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Added ${state.translations.length} translation(s)'),
              backgroundColor: Colors.green,
            ),
          );

          widget.onTranslationsAdded?.call();
        } else if (state is TranslationError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showExamples) _buildExamplesSection(),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Translations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter translations (one per line or comma-separated)',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Text input area
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      maxLines: AppLayout.translationInputMaxLines,
                      minLines: AppLayout.translationInputMinLines,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        hintText:
                            'Example:\nhello - hola\nworld - mundo\nor\nhola, mundo, adiós',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _isLoading ? null : _clearText,
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading || _textController.text.isEmpty
                            ? null
                            : _addTranslations,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add, size: 20),
                        label: const Text('Add Translations'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesSection() {
    return Card(
      color: Colors.blue.shade50,
      child: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Format Examples',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '• One per line:',
              style: TextStyle(fontSize: 13),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'hello - hola\nworld - mundo\ngoodbye - adiós',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Comma-separated:',
              style: TextStyle(fontSize: 13),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'hola, mundo, adiós, por favor',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• With alternatives (use | to separate):',
              style: TextStyle(fontSize: 13),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'hello - hola|hola qué tal\nhappy - feliz|contento|alegre',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearText() {
    _textController.clear();
    _focusNode.unfocus();
  }

  void _addTranslations() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final translations = _parseTranslations(text);

    if (translations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid translations found'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Dispatch event to BLoC
    context.read<TranslationBloc>().add(
          AddBulkTranslationsEvent(
            word_id: widget.word_id,
            translations: translations,
          ),
        );
  }

  List<Map<String, dynamic>> _parseTranslations(String text) {
    final List<Map<String, dynamic>> translations = [];

    // Split by new lines first
    final lines = text.split('\n');

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Check if line contains "-" for key-value format
      if (trimmedLine.contains('-')) {
        final parts = trimmedLine.split('-');
        if (parts.length >= 2) {
          final english = parts[0].trim();
          final translationPart = parts[1].trim();

          // Check if translation part contains alternatives (separated by |)
          if (translationPart.contains('|')) {
            final alternatives = translationPart
                .split('|')
                .map((alt) => alt.trim())
                .where((alt) => alt.isNotEmpty)
                .toList();

            if (alternatives.isNotEmpty) {
              translations.add({
                'wordTranslate': alternatives[0],
                'alternatives': alternatives.sublist(1).join('|'),
              });
            }
          } else {
            translations.add({
              'wordTranslate': translationPart,
              'alternatives': '',
            });
          }
        }
      } else {
        if (trimmedLine.contains(',')) {
          final items = trimmedLine
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();

          if (items.isNotEmpty) {
            translations.add({
              'wordTranslate': items[0],
              'alternatives': items.sublist(1).join('|'),
            });
          }
        } else {
          translations.add({
            'wordTranslate': trimmedLine,
            'alternatives': '',
          });
        }
      }
    }

    return translations;
  }
}
