import 'package:flutter/material.dart';

import '../models/postsDataModel.dart';

class PostsProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _posts = [];

  List<Map<String, dynamic>> get posts => _posts;

  void addPost(String text, List<String> images, String? videoPath) {
    final post = PostsModel(
      texts: text,
      imagePaths: images,
      videoPath: videoPath,
    ).toMap();

    _posts.insert(0, post);
    notifyListeners();
  }

  void fetchPosts() {
    notifyListeners();
  }
}
