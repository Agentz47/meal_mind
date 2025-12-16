import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../models/video_model.dart';
import '../widgets/video_recipe_card_widget.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state_widget.dart';

// Screen showing cooking videos for a recipe
// Member 3 - Videos Feature
class CookingVideoScreen extends StatefulWidget {
  final String recipeName;

  const CookingVideoScreen({
    super.key,
    required this.recipeName,
  });

  @override
  State<CookingVideoScreen> createState() => _CookingVideoScreenState();
}

class _CookingVideoScreenState extends State<CookingVideoScreen> {
  final ApiService _apiService = ApiService();
  List<VideoModel> _videos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.searchCookingVideos(widget.recipeName);
      final videosList = (result['items'] as List)
          .map((item) => VideoModel.fromJson(item))
          .toList();

      setState(() {
        _videos = videosList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load videos. Please check your API key.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Videos'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVideos,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _videos.isEmpty
                  ? const EmptyStateWidget(
                      message: 'No cooking videos found',
                      icon: Icons.video_library,
                    )
                  : ListView.builder(
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        return VideoRecipeCardWidget(
                          video: _videos[index],
                        );
                      },
                    ),
    );
  }
}
