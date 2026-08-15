import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/usecases/image/search_images.dart';
import 'package:first_app/presentation/widgets/modals/image_selection_grid.dart';

class ImageSearchDialog extends StatefulWidget {
  final String query;

  const ImageSearchDialog({super.key, required this.query});

  @override
  State<ImageSearchDialog> createState() => _ImageSearchDialogState();
}

class _ImageSearchDialogState extends State<ImageSearchDialog> {
  final SearchImagesUseCase _searchImages = sl<SearchImagesUseCase>();
  final TextEditingController _queryController = TextEditingController();

  List<ImageSearchResult>? _images;
  List<ImageSearchResult> _selected = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _queryController.text = widget.query;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
      _images = null;
      _selected = [];
    });
    try {
      final images = await _searchImages.call(query);
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

  void _backToEdit() {
    setState(() {
      _hasSearched = false;
      _images = null;
      _error = null;
      _selected = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppLayout.dialogInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * AppLayout.dialogMaxHeightRatio,
          minWidth: MediaQuery.of(context).size.width * AppLayout.dialogMinWidthRatio,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _hasSearched
                    ? 'Resultados para "${_queryController.text}"'
                    : 'Buscar imágenes',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (!_hasSearched)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'Palabra a buscar',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _search(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ],
                )
              else if (_isLoading)
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
                Expanded(
                  child: ImageSelectionGrid(
                    images: _images!,
                    initiallyMultiple: true,
                    onSelectionChanged: (selected) => _selected = selected,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_hasSearched)
                    TextButton.icon(
                      onPressed: _backToEdit,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Volver'),
                    )
                  else
                    const SizedBox.shrink(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      if (_hasSearched)
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
            ],
          ),
        ),
      ),
    );
  }
}
