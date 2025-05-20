class Book {
  final String id;
  final String title;
  final String author;
  final int year;
  final String genre;
  final String coverImageUrl;
  final String tagline;
  final String? previewLink; 

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.genre,
    required this.coverImageUrl,
    required this.tagline,
    this.previewLink,
  });

 
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String, 
      title: json['title'] as String,
      author: json['author'] as String,
      year: json['year'] as int,
      genre: json['genre'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      tagline: json['tagline'] as String,
      previewLink: json['previewLink'] as String?, 
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'year': year,
      'genre': genre,
      'coverImageUrl': coverImageUrl,
      'tagline': tagline,
      'previewLink': previewLink,
    };
  }
}