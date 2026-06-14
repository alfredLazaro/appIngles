import 'package:flutter/material.dart';

class ImageSelectionGrid extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final bool initiallyMultiple;
  final ValueChanged<List<Map<String, dynamic>>>? onSelectionChanged;

  const ImageSelectionGrid({
    super.key,
    required this.images,
    this.initiallyMultiple = false,
    this.onSelectionChanged,
  });

  @override
  State<ImageSelectionGrid> createState() => _ImageSelectionGridState();
}

class _ImageSelectionGridState extends State<ImageSelectionGrid> {
  bool _multipleSelection = false;
  final List<Map<String, dynamic>> _selected = [];

  @override
  void initState() {
    super.initState();
    _multipleSelection = widget.initiallyMultiple;
  }

  void _toggle(Map<String, dynamic> image) {
    final isSelected = _selected.contains(image);
    setState(() {
      if (_multipleSelection) {
        if (isSelected) {
          _selected.remove(image);
        } else {
          _selected.add(image);
        }
      } else {
        _selected.clear();
        if (!isSelected) {
          _selected.add(image);
        }
      }
    });
    widget.onSelectionChanged?.call(List.from(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Imágenes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: isSmall ? 0.8 : 1.0,
              child: Switch(
                value: _multipleSelection,
                onChanged: (value) {
                  setState(() {
                    _multipleSelection = value;
                    if (!value && _selected.length > 1) {
                      final first = _selected.first;
                      _selected.clear();
                      _selected.add(first);
                    }
                  });
                  widget.onSelectionChanged?.call(List.from(_selected));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: widget.images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay imágenes disponibles',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puedes continuar sin imagen',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      final image = widget.images[index];
                      final isSelected = _selected.contains(image);
                      return GestureDetector(
                        onTap: () => _toggle(image),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  image['url']['thumb'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              if (isSelected &&
                                  _multipleSelection &&
                                  _selected.length > 1)
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${_selected.indexOf(image) + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
