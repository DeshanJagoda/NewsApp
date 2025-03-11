import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  final String _apiKey = '95d24d797c734d7ca6230e6f4eca1c82'; // Your NewsAPI key
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<List<News>> fetchTopHeadlines({String category = ''}) async {
    // Construct the URL with optional category
    final url = Uri.parse(
      '$_baseUrl/top-headlines?country=us${category.isNotEmpty ? '&category=$category' : ''}&apiKey=$_apiKey',
    );

    try {
      // Make the HTTP GET request
      final response = await http.get(url);

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = json.decode(response.body);

        // Check if the 'articles' key exists in the response
        if (data['articles'] != null) {
          // Map the articles to a list of News objects
          List<News> newsList = (data['articles'] as List)
              .map((article) => News.fromJson(article))
              .toList();
          return newsList;
        } else {
          throw Exception('No articles found in the response');
        }
      } else {
        // Handle non-200 status codes
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      throw Exception('Failed to fetch news: $e');
    }
  }
}
