import 'package:flutter/material.dart';
import '../models/news.dart';

class NewsCard extends StatelessWidget {
  final News article;
  final Color cardColor;

  const NewsCard({super.key, required this.article, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor, // Use the passed cardColor
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: article.urlToImage != null
            ? Image.network(article.urlToImage!, width: 100, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 40),
        title: Text(
          article.title ?? 'No Title',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(article.description ?? 'No Description'),
      ),
    );
  }
}
