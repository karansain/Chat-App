import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseImageService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetches a random image URL from the specified [bucket].
  /// [bucket] can be 'male_profiles', 'female_profiles', etc.
  Future<String> fetchRandomImage(String bucket) async {
    try {
      // Fetch the list of all files in the bucket
      final response = await _client.storage.from(bucket).list();

      // Check if the bucket is empty
      if (response.isEmpty) {
        throw Exception("No images found in the $bucket bucket.");
      }

      // Shuffle the list to select a random image
      response.shuffle();
      final randomImage = response.first;

      // Construct the public URL for the random image
      final imageUrl = _client.storage.from(bucket).getPublicUrl(randomImage.name);

      return imageUrl;
    } catch (e) {
      // Log and rethrow the exception for error handling
      print("Error fetching image from $bucket: $e");
      throw Exception("Error fetching image: $e");
    }
  }
}
