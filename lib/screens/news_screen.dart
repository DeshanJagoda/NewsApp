import 'dart:async';
import 'package:flutter/material.dart';
import '../services/news_service.dart'; // Ensure this import points to your NewsService
import '../models/news.dart'; // Ensure this import points to your News model
import 'news_details_screen.dart'; // Ensure this import points to your NewsDetailsScreen

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<News>> _newsFuture;
  List<News> _allNews = [];
  List<News> _filteredNews = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false; // Controls visibility of the search bar
  Timer? _debounce; // For debouncing search input

  String selectedCategory = 'General'; // Category filter

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Function to fetch news data
  void _loadNews() async {
    setState(() {
      _newsFuture = NewsService().fetchTopHeadlines(category: selectedCategory);
    });

    _newsFuture.then((news) {
      setState(() {
        _allNews = news;
        _filteredNews = news;
      });
    }).catchError((error) {
      setState(() {
        _filteredNews = [];
      });
    });
  }

  // Function to filter news based on search query with debouncing
  void _filterNews(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _filteredNews = _allNews
            .where((article) =>
                article.title?.toLowerCase().contains(query.toLowerCase()) ==
                    true ||
                article.description
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ==
                    true)
            .toList();
      });
    });
  }

  // Function to toggle search bar visibility
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchFocusNode.requestFocus();
      } else {
        _searchFocusNode.unfocus();
        _searchController.clear();
        _filterNews('');
      }
    });
  }

  // Function to handle category selection
  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      _loadNews(); // Reload news based on selected category
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearchVisible
              ? TextField(
                  key: const ValueKey('searchField'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    border: InputBorder.none,
                    // ignore: deprecated_member_use
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        _filterNews('');
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterNews,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily News',
                      key: ValueKey('appBarTitle'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Stay updated with the latest news',
                      style: TextStyle(
                        fontSize: 12,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
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
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search,
                color: Colors.white),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            onSelected: _selectCategory,
            icon: const Icon(Icons.category, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'General',
                child: ListTile(
                  leading: Icon(Icons.public, color: Colors.blue),
                  title: Text('General'),
                ),
              ),
              const PopupMenuItem(
                value: 'Business',
                child: ListTile(
                  leading: Icon(Icons.business, color: Colors.green),
                  title: Text('Business'),
                ),
              ),
              const PopupMenuItem(
                value: 'Technology',
                child: ListTile(
                  leading: Icon(Icons.computer, color: Colors.orange),
                  title: Text('Technology'),
                ),
              ),
              const PopupMenuItem(
                value: 'Health',
                child: ListTile(
                  leading: Icon(Icons.health_and_safety, color: Colors.red),
                  title: Text('Health'),
                ),
              ),
              const PopupMenuItem(
                value: 'Sports',
                child: ListTile(
                  leading: Icon(Icons.sports, color: Colors.purple),
                  title: Text('Sports'),
                ),
              ),
              const PopupMenuItem(
                value: 'Entertainment',
                child: ListTile(
                  leading: Icon(Icons.movie, color: Colors.pink),
                  title: Text('Entertainment'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 170, 194, 234),
              Color.fromARGB(255, 231, 189, 239)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _loadNews();
                },
                child: FutureBuilder<List<News>>(
                  future: _newsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return _buildSkeletonLoading();
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadNews,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasData && _filteredNews.isNotEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _filteredNews.length,
                        itemBuilder: (context, index) {
                          final article = _filteredNews[index];
                          return NewsCard(article: article);
                        },
                      );
                    } else {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.article, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No articles available.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build skeleton loading
  Widget _buildSkeletonLoading() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for NewsCard
class NewsCard extends StatelessWidget {
  final News article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailsScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or placeholder
              if (article.urlToImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.urlToImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 40, color: Colors.grey),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              const SizedBox(width: 10),
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.description ?? 'No Description',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
