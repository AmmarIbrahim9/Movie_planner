import 'dart:convert';

class Movie {
  final String posterPath;
  final String overview;
  final String releaseDate;
  final List<int> genreIds;
  final int id;
  final String originalTitle;
  final String originalLanguage;
  final String title;
  final String backdropPath;
  final double popularity;
  final int voteCount;
  final String video; // Assuming this holds the video trailer key or URL
  final double voteAverage;

  bool isAddedToWatchLater; // New field for Watch Later functionality

  Movie({
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.genreIds,
    required this.id,
    required this.originalTitle,
    required this.originalLanguage,
    required this.title,
    required this.backdropPath,
    required this.popularity,
    required this.voteCount,
    required this.video,
    required this.voteAverage,
    this.isAddedToWatchLater = false, // Default to false
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      id: json['id'] ?? 0,
      originalTitle: json['original_title'] ?? '',
      originalLanguage: json['original_language'] ?? '',
      title: json['title'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      popularity: (json['popularity'] ?? 0.0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      video: '', // Initially set to empty; we'll handle this separately
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      isAddedToWatchLater: false, // Initialize Watch Later status
    );
  }

  // Method to update video field based on trailer data
  Movie copyWithTrailer(String videoKey) {
    return Movie(
      posterPath: this.posterPath,
      overview: this.overview,
      releaseDate: this.releaseDate,
      genreIds: this.genreIds,
      id: this.id,
      originalTitle: this.originalTitle,
      originalLanguage: this.originalLanguage,
      title: this.title,
      backdropPath: this.backdropPath,
      popularity: this.popularity,
      voteCount: this.voteCount,
      video: videoKey,
      voteAverage: this.voteAverage,
      isAddedToWatchLater: this.isAddedToWatchLater, // Preserve Watch Later status
    );
  }
}
