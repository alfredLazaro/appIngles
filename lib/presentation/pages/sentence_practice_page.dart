import 'package:first_app/presentation/widgets/sentence/sentence_builder.dart';
import 'package:flutter/material.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/core/services/tts_service.dart';

class SentencePracticePage extends StatefulWidget {
  final int sentenceCount;

  const SentencePracticePage({
    super.key,
    required this.sentenceCount,
  });

  @override
  State<SentencePracticePage> createState() => _SentencePracticePageState();
}

class _SentencePracticePageState extends State<SentencePracticePage> {
  final WordDao _wordDao = WordDao();
  final TtsService _ttsService = TtsService();
  final PageController _pageController = PageController();

  List<Map<String, dynamic>>? _sentences;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSentences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSentences() async {
    try {
      final sentences =
          await _wordDao.getSentencesForPractice(widget.sentenceCount);
      setState(() {
        _sentences = sentences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Ordenar Oraciones (${_currentIndex + 1}/${_sentences?.length ?? 0})'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_sentences != null ? ((_currentIndex + 1) / _sentences!.length * 100).toInt() : 0}%',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sentences == null || _sentences!.isEmpty
              ? const Center(child: Text('No hay oraciones disponibles'))
              : Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _sentences!.length,
                      minHeight: 6,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _sentences!.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final sentence = _sentences![index];
                          return SentenceBuilderWidget(
                            key: ValueKey(sentence['id']),
                            sentenceId: sentence['id'],
                            originalSentence: sentence['sentence'],
                            ttsService: _ttsService,
                          );
                        },
                      ),
                    ),
                    _buildNavigationControls(),
                  ],
                ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentIndex > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Anterior'),
          ),
          Text(
            '${_currentIndex + 1} / ${_sentences!.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: _currentIndex < _sentences!.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () => _showCompletionDialog(),
            icon: Icon(_currentIndex < _sentences!.length - 1
                ? Icons.arrow_forward
                : Icons.check_circle),
            label: Text(_currentIndex < _sentences!.length - 1
                ? 'Siguiente'
                : 'Finalizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _currentIndex < _sentences!.length - 1 ? null : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 30),
            SizedBox(width: 8),
            Text('¡Completado!'),
          ],
        ),
        content: Text('Has practicado ${_sentences!.length} oraciones.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Finalizar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
            },
            icon: const Icon(Icons.replay),
            label: const Text('Repetir'),
          ),
        ],
      ),
    );
  }
}
