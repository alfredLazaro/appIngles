import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:first_app/data/models/word_model.dart';
import 'package:first_app/data/datasources/local/word_dao.dart';

class BulkWordInsertDialog extends StatefulWidget {
  const BulkWordInsertDialog({Key? key}) : super(key: key);

  // Show dialog method
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const BulkWordInsertDialog(),
    );
  }

  @override
  State<BulkWordInsertDialog> createState() => _BulkWordInsertDialogState();
}

class _BulkWordInsertDialogState extends State<BulkWordInsertDialog> {
  final TextEditingController _textController = TextEditingController();
  final WordDao _wordDao = WordDao();

  List<Map<String, dynamic>> _insertedResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WordModel> _parseWordModels(String text) {
    try {
      // Remove extra whitespace and prepare for parsing
      final cleanText = text.trim();

      // This is a simple parser - for production, you might want a more robust solution
      final List<WordModel> words = [];

      // Split by WordModel( to find each word definition
      final wordBlocks = cleanText.split('WordModel(').skip(1);

      for (var block in wordBlocks) {
        // Extract values using regex or string manipulation
        final wordMatch =
            RegExp(r'''word:\s*['"](.+?)['"]''').firstMatch(block);
        final phoneticMatch =
            RegExp(r'''phonetic:\s*['\"](.+?)['\"]''').firstMatch(block);
        final definitionMatch =
            RegExp(r'''definition:\s*['\"](.+?)['\"]''').firstMatch(block);
        final sentenceMatch =
            RegExp(r'''sentence:\s*['\"](.+?)['\"]''').firstMatch(block);
        final learnMatch = RegExp(r"learn:\s*(\d+)").firstMatch(block);

        if (wordMatch != null) {
          words.add(WordModel(
            word: wordMatch.group(1) ?? '',
            phonetic: phoneticMatch?.group(1) ?? '',
            definition: definitionMatch?.group(1) ?? '',
            sentence: sentenceMatch?.group(1) ?? '',
            learn: int.tryParse(learnMatch?.group(1) ?? '0') ?? 0,
            createdAt: '',
            updatedAt: '',
          ));
        }
      }

      return words;
    } catch (e) {
      throw Exception('Failed to parse WordModel format: $e');
    }
  }

  Future<void> _insertWords() async {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      setState(() => _errorMessage = 'Please paste your WordModel list');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Parse the WordModel list
      final wordModels = _parseWordModels(text);

      if (wordModels.isEmpty) {
        setState(() {
          _errorMessage = 'No valid WordModels found';
          _isLoading = false;
        });
        return;
      }

      // Insert words
      final results = await _wordDao.insertLotWords(wordModels);

      setState(() {
        _insertedResults = results;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${results.length} words inserted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyResults() {
    if (_insertedResults.isEmpty) return;

    final resultText = _insertedResults
        .map((r) => 'ID: ${r['id']}, Word: ${r['word']}')
        .join('\n');

    Clipboard.setData(ClipboardData(text: resultText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Results copied to clipboard!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyResultsAsJson() {
    if (_insertedResults.isEmpty) return;

    final jsonText = _insertedResults
        .map((r) => '{"id": ${r['id']}, "word": "${r['word']}"}')
        .join(',\n  ');

    Clipboard.setData(ClipboardData(text: '[\n  $jsonText\n]'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Results copied as JSON!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bulk Word Insert',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Paste your WordModel list format:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '[\n  WordModel(\n    word: \'apple\',\n    phonetic: \'/ˈæp.əl/\',\n    definition: \'A round fruit\',\n    sentence: \'I eat an apple\',\n    learn: 0,\n  ),\n]',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.blue[900],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Text Input
            Expanded(
              flex: 2,
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste your WordModel list here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Insert Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _insertWords,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(
                _isLoading ? 'Inserting...' : 'Insert Words',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Results Section
            if (_insertedResults.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Results (${_insertedResults.length})',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: _copyResults,
                        tooltip: 'Copy as text',
                      ),
                      IconButton(
                        icon: const Icon(Icons.data_object, size: 20),
                        onPressed: _copyResultsAsJson,
                        tooltip: 'Copy as JSON',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: ListView.builder(
                    itemCount: _insertedResults.length,
                    itemBuilder: (context, index) {
                      final result = _insertedResults[index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              '${result['id']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          result['word'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text:
                                  'ID: ${result['id']}, Word: ${result['word']}',
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✓ Copied: ${result['word']}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
