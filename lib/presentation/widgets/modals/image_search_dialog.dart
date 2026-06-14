import 'package:flutter/material.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/usecases/image/search_images.dart';
import 'package:first_app/presentation/widgets/image_selection_grid.dart';

class ImageSearchDialog extends StatefulWidget {
  final String query;

  const ImageSearchDialog({super.key, required this.query});

  @override
  State<ImageSearchDialog> createState() => _ImageSearchDialogState();
}

class _ImageSearchDialogState extends State<ImageSearchDialog> {
  final SearchImagesUseCase _searchImages = sl<SearchImagesUseCase>();
  List<Map<String, dynamic>>? _images;
  List<Map<String, dynamic>> _selected = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final images = await _searchImages.call(widget.query);
      if (mounted) {
        setState(() {
          _images = images;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Buscar imágenes para "${widget.query}"',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _search,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ImageSelectionGrid(
                  images: _images!,
                  initiallyMultiple: true,
                  onSelectionChanged: (selected) => _selected = selected,
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _images != null
                        ? () => Navigator.pop(context, _selected)
                        : null,
                    child: const Text('Agregar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
