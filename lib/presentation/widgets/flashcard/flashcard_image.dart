import 'package:flutter/material.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/presentation/widgets/author_info_button.dart';

class FlashcardImageWidget extends StatelessWidget {
  final List<FlashcardImage> images;
  final double height;

  const FlashcardImageWidget({
    super.key,
    required this.images,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(context),
            if (images.isNotEmpty && images.first.author != null)
              Positioned(
                top: 10,
                right: 10,
                child: AuthorInfoButton(
                  author: images.first.author,
                  source: images.first.source,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageUrl = images.isNotEmpty
        ? images.first.url
        : FlashcardConstants.noImageAvailable;

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300],
        child: const Icon(
          Icons.image_not_supported,
          size: 60,
          color: Colors.grey,
        ),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }

}
