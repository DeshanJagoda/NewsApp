import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news.dart';

class NewsDetailsScreen extends StatelessWidget {
  final News article;

  const NewsDetailsScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Article Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _bookmarkArticle(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Placeholder
            if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
              Image.network(
                article.urlToImage!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            else
              _buildPlaceholderImage(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    article.title ?? 'No Title Available',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),

                  // Published Date
                  if (article.publishedAt != null)
                    Text(
                      'Published on: ${article.publishedAt}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Description
                  Text(
                    article.description ?? 'No Description Available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(thickness: 1),

                  // Content
                  Text(
                    article.content ?? 'No Content Available',
                    style: theme.textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),

                  // Read More Button
                  if (article.url != null && article.url!.isNotEmpty)
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _launchURL(article.url!),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Read More'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder Image Widget
  Widget _buildPlaceholderImage() {
    return Container(
      height: 250,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  // Function to share article (Replace with Share plugin if needed)
  void _shareArticle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${article.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Function to bookmark article (Future implementation)
  void _bookmarkArticle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmarked: ${article.title}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}
