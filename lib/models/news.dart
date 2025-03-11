class News {
  final String? title;
  final String? description;
  final String? content;
  final String? urlToImage;
  final String? url; // Add the url field

  News({
    this.title,
    this.description,
    this.content,
    this.urlToImage,
    this.url, // Include url in the constructor
  });

  // Factory constructor to parse JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title'],
      description: json['description'],
      content: json['content'],
      urlToImage: json['urlToImage'],
      url: json['url'], // Parse the url from JSON
    );
  }

  get publishedAt => null;
}