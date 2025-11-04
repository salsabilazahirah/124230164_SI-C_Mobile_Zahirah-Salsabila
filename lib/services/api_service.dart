import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cake_model.dart';

class ApiService {
  static const String baseUrl =
      'https://gist.githubusercontent.com/prayagKhanal/8cdd00d762c48b84a911eca2e2eb3449/raw/5c5d62797752116799aacaeeef08ea2d613569e9/cakes.json';

  Future<List<Cake>> fetchCakes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> cakesData = responseData['cakes'] ?? [];
        return cakesData.map((json) => Cake.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load cakes');
      }
    } catch (e) {
      throw Exception('Error fetching cakes: $e');
    }
  }
}
