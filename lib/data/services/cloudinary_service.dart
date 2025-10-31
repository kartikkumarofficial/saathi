// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import '../../utils/constants.dart';
//
// class CloudinaryService {
//   static const _cloudName = constants.cloudName;
//   static const _uploadPreset = constants.uploadPreset;
//
//   static Future<String?> uploadImage(File imageFile) async {
//     final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
//
//     final request = http.MultipartRequest('POST', uri)
//       ..fields['upload_preset'] = _uploadPreset
//       ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
//
//     final response = await request.send();
//     if (response.statusCode == 200) {
//       final responseData = await response.stream.bytesToString();
//       final data = jsonDecode(responseData);
//       return data['secure_url'];
//     } else {
//       print('Cloudinary upload failed: ${response.statusCode}');
//       return null;
//     }
//   }
// }




import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class CloudinaryService {
  static const _cloudName = constants.cloudName;
  static const _uploadPreset = constants.uploadPreset;
  static final _apiKey = constants.cloudApiKey; // Add to constants.dart
  static final _apiSecret = constants.cloudApiSecret; // Add to constants.dart

  /// Upload new image and delete old one if provided
  static Future<String?> uploadAndReplaceImage({
    required File imageFile,
    String? oldImageUrl,
  }) async {
    try {
      // Step 1️⃣: Upload new image
      final uploadUri =
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

      final request = http.MultipartRequest('POST', uploadUri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final uploadResponse = await request.send();

      if (uploadResponse.statusCode == 200) {
        final responseData = await uploadResponse.stream.bytesToString();
        final data = jsonDecode(responseData);
        final newImageUrl = data['secure_url'];
        final newPublicId = data['public_id'];

        // Step 2️⃣: Delete old image (if provided)
        if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
          final oldPublicId = _extractPublicId(oldImageUrl);
          if (oldPublicId != null) {
            await deleteImage(oldPublicId);
          }
        }

        return newImageUrl;
      } else {
        print('❌ Cloudinary upload failed: ${uploadResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('⚠️ Error uploading image: $e');
      return null;
    }
  }

  /// Extract public_id from Cloudinary URL
  static String? _extractPublicId(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final parts = uri.pathSegments;

      // Example path: ['image', 'upload', 'v17200000', 'folder', 'filename.jpg']
      final index = parts.indexOf('upload');
      if (index == -1 || index + 2 >= parts.length) return null;

      final publicIdWithExt =
      parts.sublist(index + 2).join('/'); // folder/filename.jpg
      final publicId = publicIdWithExt.split('.').first;
      return publicId;
    } catch (e) {
      print('⚠️ Failed to extract public ID: $e');
      return null;
    }
  }

  /// Delete image by public_id using authenticated API
  static Future<void> deleteImage(String publicId) async {
    final deleteUri =
    Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/destroy');

    final credentials = '$_apiKey:$_apiSecret';
    final basicAuth = 'Basic ${base64Encode(utf8.encode(credentials))}';

    final response = await http.post(
      deleteUri,
      headers: {'Authorization': basicAuth},
      body: {'public_id': publicId},
    );

    if (response.statusCode == 200) {
      print('🗑️ Old image deleted successfully: $publicId');
    } else {
      print('⚠️ Failed to delete image: ${response.statusCode} - ${response.body}');
    }
  }
}
