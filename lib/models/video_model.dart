// Model class representing a cooking video
class VideoModel {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String description;

  VideoModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.description,
  });

  // Create VideoModel from YouTube API JSON
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final thumbnails = snippet['thumbnails'] ?? {};
    final medium = thumbnails['medium'] ?? {};

    return VideoModel(
      id: json['id']['videoId'] ?? '',
      title: snippet['title'] ?? '',
      thumbnailUrl: medium['url'] ?? '',
      channelTitle: snippet['channelTitle'] ?? '',
      description: snippet['description'] ?? '',
    );
  }

  // Convert VideoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': {'videoId': id},
      'snippet': {
        'title': title,
        'thumbnails': {
          'medium': {'url': thumbnailUrl}
        },
        'channelTitle': channelTitle,
        'description': description,
      },
    };
  }

  // Get full YouTube URL
  String get videoUrl => 'https://www.youtube.com/watch?v=$id';
}
