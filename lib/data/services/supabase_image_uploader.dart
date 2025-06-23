import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// If you have a custom logger, import it here, otherwise use print directly.
// import 'package:e_commerce/utils/logger.dart';

class SupabaseImageUploader {
  // Ensure Supabase.instance.client is initialized before this class is used.
  // The client is final, so it fetches the instance once at creation.
  final SupabaseClient client = Supabase.instance.client;

  Future<String?> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      print('[SupabaseImageUploader] No image selected by user.');
      // appLogger.d('[SupabaseImageUploader] No image selected by user.');
      return null;
    }

    final Uint8List fileBytes = await pickedFile.readAsBytes();
    // Generate a unique file name to avoid conflicts and cache issues
    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      print(
        '[SupabaseImageUploader] Attempting to upload "$fileName" to bucket "images"...',
      );
      // appLogger.i('[SupabaseImageUploader] Attempting to upload "$fileName" to bucket "images"...');

      // The uploadBinary method returns a list of FileObject on success,
      // and throws a StorageException on failure.
      await client.storage
          .from('images') // <<-- VERIFY THIS BUCKET NAME IN SUPABASE
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600', // Cache for 1 hour
              upsert: true, // Overwrite if a file with the same name exists
            ),
          );

      // If the above line doesn't throw, the upload was successful.
      final publicUrl = client.storage.from('images').getPublicUrl(fileName);
      print(
        '[SupabaseImageUploader] Image uploaded successfully! Public URL: $publicUrl',
      );
      // appLogger.i('[SupabaseImageUploader] Image uploaded successfully! Public URL: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      // This catches specific Supabase Storage errors
      print('[SupabaseImageUploader ERROR] Storage Exception: ${e.message}');
      print('[SupabaseImageUploader ERROR] Status Code: ${e.statusCode}');
      // appLogger.e('[SupabaseImageUploader ERROR] Storage Exception: ${e.message}, Status Code: ${e.statusCode}');
      // Common status codes for debugging:
      // 400: Bad Request (e.g., malformed request, bucket not found/misspelled)
      // 401: Unauthorized (e.g., invalid JWT, no active session for RLS)
      // 403: Forbidden (MOST COMMON FOR RLS VIOLATIONS - check your bucket policies!)
      // 409: Conflict (e.g., file exists and upsert is false)
      return null;
    } catch (e) {
      // This catches any other unexpected errors
      print('[SupabaseImageUploader ERROR] General Exception: $e');
      // appLogger.e('[SupabaseImageUploader ERROR] General Exception: $e');
      return null;
    }
  }
}
