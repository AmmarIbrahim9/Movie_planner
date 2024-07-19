import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_planner/screens/sign_in.dart';
import 'package:movie_planner/screens/watch_later.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/authentication_services.dart';
import '../widgets/movie_card.dart';
import 'UserprofilePage.dart';
import 'movie_details_screen.dart';

const String apiKey = 'c351c1de7750be81fda835f9d938c1f9';
const String baseUrl = 'https://api.themoviedb.org/3';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> _movies = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  int _page = 1;
  bool _isSearching = false;
  String? _selectedGenre;
  int? _selectedYear;
  bool _sortByPopularity = false;
  final TextEditingController _pageController = TextEditingController();

  final Map<String, String> _genres = {
    'Action': '28',
    'Adventure': '12',
    'Animation': '16',
    'Comedy': '35',
    'Crime': '80',
    'Documentary': '99',
    'Drama': '18',
    'Family': '10751',
    'Fantasy': '14',
    'History': '36',
    'Horror': '27',
    'Music': '10402',
    'Mystery': '9648',
    'Romance': '10749',
    'Science Fiction': '878',
    'TV Movie': '10770',
    'Thriller': '53',
    'War': '10752',
    'Western': '37',
  };

  List<int> _years = List.generate(30, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
    _fetchMovies();
    _searchController.addListener(_onSearchChangedCallback);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onSearchChangedCallback() {
    _onSearchChanged(_searchController.text);
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _clearSearch();
      return;
    }
    _searchMovies(value);
  }

  void _fetchMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(_buildFetchUrl()),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<Movie> movies = (decoded['results'] as List)
            .map((json) => Movie.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _movies = movies; // Replace the list with the fetched movies
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        throw Exception('Failed to fetch movies');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error fetching movies: $e');
    }
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _page = 1;
      _fetchMovies();
    });
  }

  Future<void> _loadMoreMovies() async {
    setState(() {
      _page++;
      _isLoading = true;
    });

    _fetchMovies();
  }

  void _searchMovies(String query) async {
    setState(() {
      _isSearching = true;
      _isLoading = true;
      _page = 1;
    });

    try {
      final response = await http.get(
        Uri.parse(_buildSearchUrl(query)),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<Movie> movies = (decoded['results'] as List)
            .map((json) => Movie.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _movies = movies; // Replace the list for search results
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        throw Exception('Failed to fetch movies');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error searching movies: $e');
    }
  }

  String _buildFetchUrl() {
    String url = '$baseUrl/discover/movie?api_key=$apiKey&page=$_page';

    if (_selectedGenre != null) {
      url += '&with_genres=${_genres[_selectedGenre]}';
    }

    if (_selectedYear != null) {
      url += '&primary_release_year=$_selectedYear';
    }

    if (_sortByPopularity) {
      url += '&sort_by=popularity.desc';
    }

    url += '&page_size=10'; // Limit results to 10 per page

    return url;
  }

  String _buildSearchUrl(String query) {
    String url =
        '$baseUrl/search/movie?api_key=$apiKey&query=$query&page=$_page';

    if (_selectedGenre != null) {
      url += '&with_genres=${_genres[_selectedGenre]}';
    }

    if (_selectedYear != null) {
      url += '&primary_release_year=$_selectedYear';
    }

    if (_sortByPopularity) {
      url += '&sort_by=popularity.desc';
    }

    url += '&page_size=10'; // Limit results to 10 per page

    return url;
  }

  void _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  void _jumpToPage(int pageNumber) {
    setState(() {
      _page = pageNumber;
      _isLoading = true;
    });

    _fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search movies...',
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.black),
          onChanged: _onSearchChanged,
        )
            : Text('Movie Night Planner'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _clearSearch();
                }
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.blueGrey[900],
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: _logout,
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.blueGrey[900],
              ),
              title: Text(
                'User Profile',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.watch_later,
                color: Colors.blueGrey[900],
              ),
              title: Text(
                'Watch Later',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WatchLaterPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailsScreen(movie: _movies[index]),
                      ),
                    );
                  },
                  child: MovieCard(movie: _movies[index]),
                );
              },
            ),
          ),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 4,
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: _selectedGenre,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGenre = newValue;
                        _clearSearch();
                      });
                    },
                    items: _genres.keys
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: _selectedGenre == value
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<int>(
                    hint: Text('Select Year',
                        style: TextStyle(color: Colors.white)),
                    value: _selectedYear,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                        _clearSearch();
                      });
                    },
                    items: _years.map<DropdownMenuItem<int>>((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color: _selectedYear == year
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Row(
              children: [
                SizedBox(width: 1),
                ElevatedButton(
                  onPressed: () {
                    _clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Background color for reset button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Reset Filters',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedGenre = null;
      _selectedYear = null;
      _sortByPopularity = false;
      _clearSearch();
    });
  }


  Widget _buildPaginationControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _page > 1 ? _loadPreviousPage : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Previous'),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: _loadMoreMovies,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Next'),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              width: 80,
              child: TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Page $_page', // Display current page number here
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              int? pageNumber = int.tryParse(_pageController.text);
              if (pageNumber != null && pageNumber > 0) {
                _jumpToPage(pageNumber);
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Go'),
          ),
        ],
      ),
    );
  }


  void _loadPreviousPage() {
    if (_page > 1) {
      setState(() {
        _page--;
        _isLoading = true;
      });

      _fetchMovies();
    }
  }
}
