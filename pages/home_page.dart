import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/book_data_loader.dart';
import '../widgets/book_card.dart';
import 'book_detail_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  List<String> _genres = [];
  String? _selectedGenre;
  bool _isLoading = true;
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookData();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookData() async {
    setState(() => _isLoading = true);
    _allBooks = await BookDataLoader.loadBooks();
    _genres = ['All'] + BookDataLoader.getUniqueGenres(_allBooks);
    _selectedGenre = _genres.isNotEmpty ? _genres[0] : null;
    _filterBooks();
    setState(() => _isLoading = false);
  }

  void _refreshHomePage() {
    setState(() {
      _filterBooks();
    });
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final titleMatch = book.title.toLowerCase().contains(query);
        final authorMatch = book.author.toLowerCase().contains(query);
        final genreMatch = _selectedGenre == 'All' || book.genre == _selectedGenre;
        return (titleMatch || authorMatch) && genreMatch;
      }).toList();
    });
  }

  void _onGenreSelected(String? genre) {
    if (genre == null) return;
    setState(() => _selectedGenre = genre);
    _filterBooks();
  }

  void _navigateToDetail(Book book) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(
          book: book,
          onFavoriteToggle: _refreshHomePage,
        ),
      ),
    );
    _refreshHomePage();
  }

  void _navigateToFavorites() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoritesPage()),
    );
    _refreshHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/perfect_forest.jpg',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2D4D2F), Colors.grey],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.white, size: 30),
                                onPressed: _navigateToFavorites,
                                tooltip: 'View Favorites',
                              ),
                            ),
                            const Text(
                              'Book Explorer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 55,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                                shadows: [
                                  Shadow(
                                    offset: Offset(-7.5, 0),
                                    blurRadius: 3,
                                    color: Color.fromARGB(204, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your Reading Journey Starts Here',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '"A room without books is like a body without a soul." \n \n',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withAlpha((0.9 * 255).round()),
                                hintText: 'Search by Title or Author',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_genres.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 6.0,
                              runSpacing: 2.0,
                              children: _genres.map((genre) {
                                return ChoiceChip(
                                  label: Text(genre, style: const TextStyle(fontSize: 12)),
                                  selected: _selectedGenre == genre,
                                  onSelected: (selected) {
                                    if (selected) {
                                      _onGenreSelected(genre);
                                    }
                                  },
                                  selectedColor: Colors.green.shade200,
                                  backgroundColor: Colors.white70,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.grid_view,
                                color: _isGridView ? Colors.green : Colors.white70,
                              ),
                              onPressed: () {
                                setState(() => _isGridView = true);
                              },
                              tooltip: 'Grid View',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.list,
                                color: !_isGridView ? Colors.green : Colors.white70,
                              ),
                              onPressed: () {
                                setState(() => _isGridView = false);
                              },
                              tooltip: 'List View',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _filteredBooks.isEmpty
                            ? const Center(
                                child: Text(
                                  'No books found.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : _isGridView
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(6.0),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      childAspectRatio: 0.75,
                                      crossAxisSpacing: 6,
                                      mainAxisSpacing: 6,
                                    ),
                                    itemCount: _filteredBooks.length,
                                    itemBuilder: (context, index) {
                                      final book = _filteredBooks[index];
                                      return BookCard(
                                        book: book,
                                        onTap: () => _navigateToDetail(book),
                                        isListView: false,
                                        onFavoriteToggle: _refreshHomePage,
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(6.0),
                                    itemCount: _filteredBooks.length,
                                    itemBuilder: (context, index) {
                                      final book = _filteredBooks[index];
                                      return BookCard(
                                        book: book,
                                        onTap: () => _navigateToDetail(book),
                                        isListView: true,
                                        onFavoriteToggle: _refreshHomePage,
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
