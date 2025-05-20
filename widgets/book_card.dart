import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book_model.dart';
import 'dart:convert';

class BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final bool isListView;
  final VoidCallback? onFavoriteToggle;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.isListView = false,
    this.onFavoriteToggle,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool isFavorite = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  void didUpdateWidget(covariant BookCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteJsonList = prefs.getStringList('favoriteBooks') ?? [];
    final isFav = favoriteJsonList.any((jsonString) {
      try {
        final bookMap = json.decode(jsonString) as Map<String, dynamic>;
        return bookMap['id'] == widget.book.id;
      } catch (e) {
        return false;
      }
    });
    if (isFavorite != isFav) {
      setState(() {
        isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteJsonList = prefs.getStringList('favoriteBooks') ?? [];

    if (isFavorite) {
      favoriteJsonList.removeWhere((jsonString) {
        try {
          final bookMap = json.decode(jsonString) as Map<String, dynamic>;
          return bookMap['id'] == widget.book.id;
        } catch (e) {
          return false;
        }
      });
    } else {
      favoriteJsonList.add(json.encode(widget.book.toJson()));
    }

    await prefs.setStringList('favoriteBooks', favoriteJsonList);
    setState(() {
      isFavorite = !isFavorite;
    });

    widget.onFavoriteToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          elevation: 4.0,
          margin: widget.isListView
              ? const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0)
              : const EdgeInsets.all(6.0),
          clipBehavior: Clip.antiAlias,
          color: Colors.white.withAlpha((0.2 * 255).round()),
          child: InkWell(
            onTap: widget.onTap,
            child: widget.isListView
                ? _buildListLayout(context)
                : _buildGridLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                widget.book.coverImageUrl,
                height: 170,
                width: 120,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 170,
                    width: 120,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    width: 110,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.book.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.book.tagline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 15,
                  color: Colors.black87,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Opacity(
              opacity: 0.85,
              child: Image.network(
                widget.book.coverImageUrl,
                height: 100,
                width: 75,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 100,
                    width: 75,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 75,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.book.tagline,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
    );
  }
}
