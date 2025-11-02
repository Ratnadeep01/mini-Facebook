class PostsModel {
  String texts;
  List<String> imagePaths;
  String? videoPath;

  PostsModel({
    required this.texts,
    required this.imagePaths,
    required this.videoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      "postId": DateTime.now().millisecondsSinceEpoch.toString(),
      "user": {
        "name": "You",
        "profileImage": "https://i.pravatar.cc/150?img=8",
      },
      "content": {
        "text": texts.trim(),
        "images": imagePaths,
        "video": videoPath,
      },
      "likes": 0,
      "commentsCount": 2,
      "timestamp": DateTime.now(),
      "comments": [
        {
          "user": {
            "name": "Jane Smith",
            "profileImage": "https://i.pravatar.cc/150?img=2",
          },
          "text": "Looks amazing!",
          "timestamp": DateTime.now(),
        },
        {
          "user": {
            "name": "Mike Ross",
            "profileImage": "https://i.pravatar.cc/150?img=3",
          },
          "text": "Wow! Which part of the city?",
          "timestamp": DateTime.now(),
        },
      ],
    };
  }
}
