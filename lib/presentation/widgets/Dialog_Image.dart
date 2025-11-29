import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class ImageSelectorDialog extends StatefulWidget {
  final List<Map<String, dynamic>> imageUrls;
  final bool allowMultipleSelection;
  const ImageSelectorDialog({
    super.key,
    required this.imageUrls,
    this.allowMultipleSelection = false,
  });
  @override
  _ImageSelectorDialogState createState() => _ImageSelectorDialogState();
}

class _ImageSelectorDialogState extends State<ImageSelectorDialog> {
  final List<Map<String, dynamic>> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Seleccina imagenes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: widget.imageUrls.length,
                        itemBuilder: (context, index) {
                          final imageUrl = widget.imageUrls[index];
                          final isSelected = _selectedImages.contains(imageUrl);

                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedImages.remove(imageUrl);
                                  } else {
                                    if (widget.allowMultipleSelection) {
                                      _selectedImages.add(imageUrl);
                                    } else {
                                      _selectedImages.clear();
                                      _selectedImages.add(imageUrl);
                                    }
                                  }
                                });
                              },
                              child: Stack(fit: StackFit.expand, children: [
                                CachedNetworkImage(
                                    imageUrl: imageUrl['url']['regular'] ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error)),
                                if (isSelected)
                                  Container(
                                    color: Colors.black.withOpacity(0.4),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  )
                              ]));
                        }),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _selectedImages.isNotEmpty
                          ? () {
                              Logger().i(
                                  'Imagenes seleccionadas: $_selectedImages');
                              Navigator.of(context).pop(_selectedImages);
                            }
                          : null,
                      child: const Text('confirmar'),
                    ),
                  ])
                ],
              ))),
    );
  }
}
