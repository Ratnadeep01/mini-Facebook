import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:yolo/services/postsProviderServices.dart';

class AppService {
  final ImagePicker _picker = ImagePicker();

  Future<List<File>> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images.map((xfile) => File(xfile.path)).toList();
  }

  Future<File?> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video != null ? File(video.path) : null;
  }

  Future<String> saveFileToFolder(File file, String folderName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory targetDir = Directory('${appDir.path}/$folderName');

    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }

    final String newPath =
        '${targetDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    final File newFile = await file.copy(newPath);
    return newFile.path;
  }

  Future<void> savePost({
    required String text,
    required List<File> selectedImages,
    File? selectedVideo,
    required BuildContext context,
  }) async {
    if (text.trim().isEmpty) {
      throw Exception("Post text cannot be empty.");
    }

    List<String> imagePaths = [];
    String? videoPath;

    for (File img in selectedImages) {
      imagePaths.add(await saveFileToFolder(img, 'images'));
    }

    if (selectedVideo != null) {
      videoPath = await saveFileToFolder(selectedVideo, 'videos');
    }
    context.read<PostsProvider>().addPost(text, imagePaths, videoPath);
  }
}
