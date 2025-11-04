import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileApiService {
  static const String baseUrl =
      'https://api-gunung-23024569990.uscentral1.run.app/api/users';

  static const Duration timeoutDuration = Duration(seconds: 30);

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String fullName,
    String? profilePicture,
    String? password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/profile');

      final body = {'user_id': userId, 'full_name': fullName};

      // Add optional fields if provided
      if (profilePicture != null && profilePicture.isNotEmpty) {
        body['profile_picture'] = profilePicture;
      }

      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(timeoutDuration);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
          'error': responseData['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Failed to connect to server',
        'error': e.toString(),
      };
    }
  }

  /// Delete user account
  Future<Map<String, dynamic>> deleteAccount(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/$userId');

      final response = await http
          .delete(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(timeoutDuration);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete account',
          'error': responseData['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: Failed to connect to server',
        'error': e.toString(),
      };
    }
  }

  /// Validate profile picture URL
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final path = uri.path.toLowerCase();

    return validExtensions.any((ext) => path.endsWith(ext)) ||
        url.contains('imgur.com') ||
        url.contains('cloudinary.com') ||
        url.contains('unsplash.com') ||
        url.contains('pexels.com');
  }
}
