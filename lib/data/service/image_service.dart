import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final imageServiceProvider = Provider<ImageService>(
  (ref) => ImageService(),
);

class ImageService {
  final ImagePickerPlugin _picker = ImagePickerPlugin();

  Future<Uint8List?> pickAndCompressImage({
    int quality = 85,
    int maxImageWidth = 1920,
    int maxImageHeight = 1080,
  }) async {
    try {
      final pickedImage = await _picker.getImageFromSource(
        source: ImageSource.gallery,
      );

      if (pickedImage == null) return null;

      final bytes = await pickedImage.readAsBytes();
      final compressBytes = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: maxImageWidth,
        minHeight: maxImageHeight,
        format: CompressFormat.jpeg,
      );

      return Uint8List.fromList(compressBytes);
    } catch (e) {
      throw Exception('Pick and compress image exception: $e');
    }
  }

  double getImageSizeInMB(Uint8List imageBytes) {
    return imageBytes.length / (1024 * 1024);
  }
}
