import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:flutter/material.dart';

class TranslationSection extends StatefulWidget {
  final List<TranslationEntity> translations;
  final bool isEditing;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const TranslationSection({
    super.key,
    required this.translations,
    required this.isEditing,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<TranslationSection> createState() => _TranslationSectionState();
}

class _TranslationSectionState extends State<TranslationSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTranslation() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.translate, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            const Text(AppStrings.translations,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (widget.translations.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text('(${widget.translations.length})',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (widget.translations.isEmpty && !widget.isEditing)
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 4, bottom: 4),
            child: Text(AppStrings.noTranslations,
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
        ...List.generate(widget.translations.length, (i) {
          final t = widget.translations[i];
          return Padding(
            padding: const EdgeInsets.only(left: 32, top: 4, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(t.wordTranslate,
                      style: const TextStyle(fontSize: 15)),
                ),
                if (widget.isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () => widget.onRemove(i),
                  ),
              ],
            ),
          );
        }),
        if (widget.isEditing) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nueva traducción',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}
