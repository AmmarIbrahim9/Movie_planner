// watch_later_page.dart

import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_details_screen.dart';

List<Movie> watchLaterMovies = []; // List to hold watch later movies

class WatchLaterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch Later'),
      ),
      body:
        Text("Coming in the next update ! ",style: TextStyle(fontSize: 24),)
      // ListView.builder(
      //
      //   itemCount: watchLaterMovies.length,
      //   itemBuilder: (context, index) {
      //     return ListTile(
      //
      //       // title: Text(watchLaterMovies[index].title),
      //       subtitle: Text(watchLaterMovies[index].overview),
      //       onTap: () {
      //         // Navigator.push(
      //         //   context,
      //         //   MaterialPageRoute(
      //         //     builder: (context) => MovieDetailsScreen(movie: watchLaterMovies[index]),
      //         //   ),
      //         // );
      //       },
      //     );
      //   },
      // ),
    );
  }
}
