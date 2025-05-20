import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart'; 
import '../models/book_model.dart';

final Logger _logger = Logger();

class BookDataLoader {
  // Method to load books from the local JSON asset
  static Future<List<Book>> loadBooks() async {
    try {
      // Load the JSON string from the asset file
      final String jsonString = await rootBundle.loadString('assets/books.json');

      // Decode the JSON string into a List<dynamic>
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Map each JSON object in the list to a Book object
      final List<Book> books = jsonList
          .map((jsonItem) => Book.fromJson(jsonItem as Map<String, dynamic>))
          .toList();

      _logger.i('Successfully loaded ${books.length} books.'); // Use info level for success
      return books;
    } catch (e, stackTrace) { // Capture stack trace for better debugging
      // Handle potential errors during loading or parsing
      _logger.e('Error loading books: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Get unique genres from a list of books
  static List<String> getUniqueGenres(List<Book> books) {
    final Set<String> genres = {}; // Set to automatically handle uniqueness
    for (var book in books) {
      genres.add(book.genre);
    }
    _logger.d('Generated unique genres. Total: ${genres.length}'); // Use debug level for informational messages
    return genres.toList()..sort(); // Convert Set to List and sort
  }
}