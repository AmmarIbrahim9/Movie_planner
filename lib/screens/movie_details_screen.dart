import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_planner/screens/watch_later.dart';
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie.dart';
import 'trailer_screen.dart';
import 'sharemovie_screen.dart';
 // Import the WatchLaterPage

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  MovieDetailsScreen({required this.movie});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Movie _movie;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
  }

  Future<void> playTrailer(BuildContext context) async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/movie/${_movie.id}/videos?api_key=c351c1de7750be81fda835f9d938c1f9',
      ),
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['results'].isNotEmpty) {
        String videoKey = jsonData['results'][0]['key'];
        String videoId = _extractVideoId(jsonData['results'][0]['key']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrailerScreen(videoId: videoId),
          ),
        );
      } else {
        _showNoTrailerDialog(context);
      }
    } else {
      throw Exception('Failed to load trailer');
    }
  }

  void _showNoTrailerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No Trailer Available'),
        content: Text(
          'Sorry, there is no trailer available for this movie.',
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _extractVideoId(String youtubeUrl) {
    return YoutubePlayer.convertUrlToId(youtubeUrl) ?? '';
  }

  void _shareMovie(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareMovieScreen(movie: _movie),
      ),
    );
  }

  // void _toggleWatchLater() {
  //   setState(() {
  //     _movie.isAddedToWatchLater = !_movie.isAddedToWatchLater;
  //     if (_movie.isAddedToWatchLater) {
  //       // Add to watch later list
  //       watchLaterMovies.add(_movie);
  //     } else {
  //       // Remove from watch later list
  //       watchLaterMovies.removeWhere((movie) => movie.id == _movie.id);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          _movie.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: _movie.isAddedToWatchLater
                ? Icon(Icons.watch_later, color: Colors.white)
                : Icon(Icons.watch_later_outlined, color: Colors.white),
            onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WatchLaterPage()),
                );

              // _toggleWatchLater();
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareMovie(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: 'movie-${_movie.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${_movie.backdropPath}',
                  fit: BoxFit.cover,
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'Overview',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              _movie.overview,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 24.0),
            Text(
              'Release Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              _movie.releaseDate,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                playTrailer(context);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                child: Text(
                  'Play Trailer',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
