import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../models/book_model.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, 
    errorMethodCount: 8, 
    lineLength: 120, 
    colors: true, 
    printEmojis: true, 
    dateTimeFormat: DateTimeFormat.none,
  ),
);


class BookDetailPage extends StatefulWidget {
  final Book book;
  final VoidCallback? onFavoriteToggle; //Callback for favorite changes

  const BookDetailPage({
    Key? key,
    required this.book,
    this.onFavoriteToggle, // Initialize the callback
  }) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Check for favorite status using book ID
  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJsonList = prefs.getStringList('favoriteBooks') ?? [];
    setState(() {
      _isFavorite = favoriteJsonList.any((jsonString) {
        try {
          final bookMap = json.decode(jsonString) as Map<String, dynamic>;
          // 'id' is a unique identifier for books
          return bookMap['id'] == widget.book.id;
        } catch (e) {
          // Using logger for errors
          logger.e('Error decoding favorite book JSON: $e, JSON: $jsonString');
          return false;
        }
      });
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteJsonList = prefs.getStringList('favoriteBooks') ?? [];
    if (_isFavorite) {
      // Removing book by comparing ID
      favoriteJsonList.removeWhere(
        (jsonString) {
          try {
            final bookMap = json.decode(jsonString) as Map<String, dynamic>;
            return bookMap['id'] == widget.book.id;
          } catch (e) {
            // Using logger for errors
            logger.e('Error decoding favorite book JSON during removal: $e, JSON: $jsonString');
            return false;
          }
        },
      );
    } else {
      // Add the current book to favorites
      favoriteJsonList.add(json.encode(widget.book.toJson()));
    }

    await prefs.setStringList('favoriteBooks', favoriteJsonList);

    if (!mounted) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites!' : 'Removed from favorites.'),
        duration: const Duration(seconds: 1),
      ),
    );

    // Call the callback to notify parent widgets (HomePage)
    widget.onFavoriteToggle?.call();
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      // Use logger for informational messages
      logger.i('No preview link provided.');
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Use logger for errors
      logger.e('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme vintageGreenColorScheme = ColorScheme.light(
      primary: const Color(0xFF4A6B5B),
      onPrimary: Colors.white,
      secondary: const Color(0xFF82A69A),
      onSecondary: Colors.white,
      surface: const Color(0xFFF0F5ED),
      onSurface: const Color(0xFF333333),
      shadow: const Color(0xFFE0E5DB),
      error: Colors.red[700]!,
      onError: Colors.white,
    );
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: vintageGreenColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: vintageGreenColorScheme.primary,
          foregroundColor: vintageGreenColorScheme.onPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: vintageGreenColorScheme.onPrimary,
            backgroundColor: vintageGreenColorScheme.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: vintageGreenColorScheme.surface,
          labelStyle: TextStyle(color: vintageGreenColorScheme.onSurface),
        ),
        cardTheme: CardTheme(
          color: vintageGreenColorScheme.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              // You might want to define text styles here for consistency
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.book.title),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : vintageGreenColorScheme.onPrimary,
              ),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                vintageGreenColorScheme.shadow,
                vintageGreenColorScheme.surface,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.3 * 255).round()),
                          spreadRadius: 4,
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Image.network(
                        widget.book.coverImageUrl,
                        height: 450,
                        width: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Log image loading errors
                          logger.e('Error loading image for ${widget.book.title}: $error');
                          return Container(
                            height: 450,
                            width: 300,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 90, color: Colors.grey),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 450,
                            width: 300,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: vintageGreenColorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Text(
                  'By ${widget.book.author}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: vintageGreenColorScheme.onSurface.withAlpha((0.8 * 255).round()),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25.0),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoChip(context, widget.book.genre, Icons.category),
                        _buildInfoChip(context, 'Published: ${widget.book.year}', Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Summary',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: vintageGreenColorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  widget.book.tagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: vintageGreenColorScheme.onSurface,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 35.0),
                if (widget.book.previewLink != null && widget.book.previewLink!.isNotEmpty)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Read Preview', style: TextStyle(fontSize: 19)),
                    onPressed: () => _launchURL(widget.book.previewLink),
                  )
                else
                  Text(
                    'No preview link available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      label: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}