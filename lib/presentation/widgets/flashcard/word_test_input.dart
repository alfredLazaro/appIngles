import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';

class WordTestInput extends StatefulWidget {
  final Function(String) onSubmit;
  final BoxConstraints constraints;

  const WordTestInput({
    super.key,
    required this.onSubmit,
    required this.constraints,
  });

  @override
  State<WordTestInput> createState() => _WordTestInputState();
}

class _WordTestInputState extends State<WordTestInput> {
  late final TextEditingController _controller;

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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: FlashcardConstants.testInputLabel,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.all(widget.constraints.maxHeight * 0.015),
            ),
            onSubmitted: (value) {
              widget.onSubmit(value);
              _controller.clear();
            },
          ),
        ),
        SizedBox(width: widget.constraints.maxWidth * 0.02),
        Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: () {
              widget.onSubmit(_controller.text);
              _controller.clear();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(widget.constraints.maxHeight * 0.015),
            ),
            child: Icon(
              Icons.send,
              size: widget.constraints.maxHeight * 0.04,
            ),
          ),
        ),
      ],
    );
  }
}
