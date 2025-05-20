import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book_model.dart';
import '../widgets/book_card.dart';
import 'book_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Book> _favoriteBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true; // Show loading indicator while reloading
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteJsonList = prefs.getStringList('favoriteBooks') ?? [];
      setState(() {
        _favoriteBooks = favoriteJsonList.map((jsonString) {
          final bookMap = json.decode(jsonString) as Map<String, dynamic>;
          return Book.fromJson(bookMap);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4D9),
      appBar: AppBar(
        title: const Text(
          'Your Cherished Reads',
          style: TextStyle(
            color: Color(0xFF2D4D2F),
            fontFamily: 'OldStandardTT',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFA5B899),
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA5B899), Color(0xFF7E967D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteBooks.isEmpty
              ? const Center(
                  child: Text(
                    'No favorites yet. Start exploring!',
                    style: TextStyle(
                      color: Color(0xFF2D4D2F),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: _favoriteBooks.length,
                  itemBuilder: (context, index) {
                    final book = _favoriteBooks[index];
                    return BookCard(
                      book: book,
                      onTap: () async {
                        // Await the push to ensure the detail page is popped before reloading
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailPage(
                              book: book,
                              onFavoriteToggle: _loadFavorites, // Pass the callback
                            ),
                          ),
                        );
                        _loadFavorites(); // Reload when returning from detail page
                      },
                      onFavoriteToggle: _loadFavorites, // Pass the callback
                    );
                  },
                ),
    );
  }
}
