import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/domain/repositories/translation_repository.dart';
import 'package:first_app/domain/repositories/word_repository.dart';
import 'package:first_app/domain/usecases/word/delete_word.dart';
import 'package:first_app/presentation/widgets/learn_progress_indicator.dart';
import 'package:flutter/material.dart';

class WordDetailScreen extends StatefulWidget {
  final WordWithImage wordWithImage;
  final VoidCallback onWordUpdated;

  const WordDetailScreen({
    super.key,
    required this.wordWithImage,
    required this.onWordUpdated,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final WordRepository _repository = sl<WordRepository>();
  final TranslationRepository _translationRepository =
      sl<TranslationRepository>();
  final TtsService _ttsService = sl<TtsService>();
  final DeleteWordUseCase _deleteWordUseCase = sl<DeleteWordUseCase>();

  Word? _word;
  List<TranslationEntity> _translations = [];
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _wordController;
  late TextEditingController _definitionController;
  late TextEditingController _sentenceController;
  late TextEditingController _phoneticController;
  late TextEditingController _newTranslationController;

  final Set<int> _translationsToDelete = {};

  @override
  void initState() {
    super.initState();
    _newTranslationController = TextEditingController();
    _loadWord();
  }

  Future<void> _loadWord() async {
    try {
      final results = await Future.wait([
        _repository.getWordById(widget.wordWithImage.id),
        _translationRepository.getTranslationsByWordId(
            widget.wordWithImage.id),
      ]);
      final word = results[0] as Word?;
      final translations = results[1] as List<TranslationEntity>;
      if (mounted) {
        setState(() {
          _word = word;
          _translations = translations;
          _isLoading = false;
          if (word != null) {
            _initControllers(word);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initControllers(Word word) {
    _wordController = TextEditingController(text: word.word);
    _definitionController = TextEditingController(text: word.definition);
    _sentenceController = TextEditingController(text: word.sentence);
    _phoneticController = TextEditingController(text: word.phonetic);
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _sentenceController.dispose();
    _phoneticController.dispose();
    _newTranslationController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await _ttsService.speak(text);
    } catch (e) {
      // ignore
    }
  }

  void _toggleEditing() {
    if (!mounted) return;
    if (_isEditing) {
      _cancelEditing();
    } else {
      setState(() {
        _isEditing = true;
        _translationsToDelete.clear();
        _newTranslationController.clear();
      });
    }
  }

  void _cancelEditing() {
    if (_word == null) return;
    setState(() {
      _isEditing = false;
      _wordController.text = _word!.word;
      _definitionController.text = _word!.definition;
      _sentenceController.text = _word!.sentence;
      _phoneticController.text = _word!.phonetic;
      _translationsToDelete.clear();
      _newTranslationController.clear();
    });
  }

  void _addTranslation() {
    final text = _newTranslationController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _translations.add(TranslationEntity(
        wordId: widget.wordWithImage.id,
        wordTranslate: text,
      ));
      _newTranslationController.clear();
    });
  }

  void _markTranslationToDelete(int index) {
    final translation = _translations[index];
    if (translation.id != null) {
      _translationsToDelete.add(translation.id!);
    }
    setState(() => _translations.removeAt(index));
  }

  Future<void> _save() async {
    if (_word == null) return;

    final updatedWord = _word!.copyWith(
      word: _wordController.text.trim(),
      definition: _definitionController.text.trim(),
      sentence: _sentenceController.text.trim(),
      phonetic: _phoneticController.text.trim(),
    );

    setState(() => _isSaving = true);

    try {
      await _repository.updateWord(updatedWord);

      for (final id in _translationsToDelete) {
        await _translationRepository.deleteTranslation(id);
      }
      final newTranslations = _translations
          .where((t) => t.id == null)
          .toList();
      if (newTranslations.isNotEmpty) {
        await _translationRepository
            .insertTranslations(widget.wordWithImage.id, newTranslations);
      }

      final reloadedTranslations = await _translationRepository
          .getTranslationsByWordId(widget.wordWithImage.id);

      if (mounted) {
        setState(() {
          _word = updatedWord;
          _translations = reloadedTranslations;
          _translationsToDelete.clear();
          _newTranslationController.clear();
          _isEditing = false;
          _isSaving = false;
        });
        widget.onWordUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palabra actualizada')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar palabra'),
        content: Text('¿Eliminar "${widget.wordWithImage.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _deleteWordUseCase.call(widget.wordWithImage.id);
      if (mounted) {
        widget.onWordUpdated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_word?.word ?? widget.wordWithImage.word),
        centerTitle: true,
        actions: [
          if (_word != null) ...[
            if (_isEditing)
              IconButton(
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check),
                onPressed: _isSaving ? null : _save,
              )
            else
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _toggleEditing,
              ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _word == null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No se pudo cargar la palabra'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadWord,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLearnProgress(),
                const SizedBox(height: 16),
                if (_isEditing) ...[
                  _buildEditableField('Palabra', _wordController,
                      onTapSpeak: () => _speak(_wordController.text)),
                  const SizedBox(height: 12),
                  _buildEditableField('Fonética', _phoneticController),
                  const SizedBox(height: 12),
                  _buildEditableField(
                      'Definición', _definitionController,
                      maxLines: 3),
                  const SizedBox(height: 12),
                  _buildEditableField('Oración', _sentenceController,
                      maxLines: 3),
                ] else ...[
                  _buildInfoRow(Icons.text_fields, 'Palabra', _word!.word,
                      onTap: () => _speak(_word!.word)),
                  if (_word!.phonetic.isNotEmpty)
                    _buildInfoRow(
                        Icons.phonelink, 'Fonética', _word!.phonetic),
                  _buildInfoRow(
                      Icons.description, 'Definición', _word!.definition),
                  if (_word!.sentence.isNotEmpty)
                    _buildInfoRow(
                        Icons.format_quote, 'Oración', _word!.sentence),
                ],
                const SizedBox(height: 20),
                _buildTranslationsSection(),
                const SizedBox(height: 24),
                if (!_isEditing) _buildDeleteButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final imageUrl = widget.wordWithImage.tinyImageUrl;
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[200],
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.image_not_supported,
                    size: 64, color: Colors.grey),
              ),
            )
          : const Center(
              child: Icon(Icons.image_not_supported,
                  size: 64, color: Colors.grey),
            ),
    );
  }

  Widget _buildLearnProgress() {
    return Row(
      children: [
        LearnProgressIndicator(learnValue: widget.wordWithImage.learn),
        const SizedBox(width: 8),
        Text('${widget.wordWithImage.learn} % aprendido'),
      ],
    );
  }

  Widget _buildTranslationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.translate, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            const Text('Traducciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (_translations.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text('(${_translations.length})',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_translations.isEmpty && !_isEditing)
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 4, bottom: 4),
            child: Text('Sin traducciones',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
        ...List.generate(_translations.length, (i) {
          final t = _translations[i];
          return Padding(
            padding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(t.wordTranslate,
                      style: const TextStyle(fontSize: 15)),
                ),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () => _markTranslationToDelete(i),
                  ),
              ],
            ),
          );
        }),
        if (_isEditing) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTranslationController,
                    decoration: const InputDecoration(
                      hintText: 'Nueva traducción',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _addTranslation(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                  onPressed: _addTranslation,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onTap,
                  child: Text(value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration:
                            onTap != null ? TextDecoration.underline : null,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1, VoidCallback? onTapSpeak}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
            if (onTapSpeak != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: onTapSpeak,
                child: const Icon(Icons.volume_up,
                    size: 18, color: Colors.blue),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _delete,
        icon: const Icon(Icons.delete, color: Colors.red),
        label: const Text('Eliminar palabra',
            style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
