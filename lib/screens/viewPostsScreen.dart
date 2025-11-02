import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yolo/widgets/videoPlayer.widget.dart';

import '../services/postsProviderServices.dart';
import 'createPostsScreen.dart';

class HomeFeedPage extends StatefulWidget {
  const HomeFeedPage({super.key});

  @override
  State<HomeFeedPage> createState() => _HomeFeedPageState();
}

class _HomeFeedPageState extends State<HomeFeedPage> {
  final Set<int> likedPosts = {};

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _refreshPosts(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    context.read<PostsProvider>().fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final feeds = context.watch<PostsProvider>().posts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Facebook Feed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshPosts(context),
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        child: feeds.isEmpty
            ? const Center(
                child: Text(
                  "Add Posts",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: feeds.length,
                itemBuilder: (context, index) {
                  final post = feeds[index];
                  final user = post["user"];
                  final content = post["content"];
                  final images = List<String>.from(content["images"] ?? []);
                  final video = content["video"];
                  final timestamp = post["timestamp"] as DateTime;
                  final List<String> mediaItems = [...images];
                  if (video != null && video.isNotEmpty) mediaItems.add(video);

                  final bool isLiked = likedPosts.contains(index);

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user["profileImage"],
                                ),
                                radius: 22,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    timeAgo(timestamp),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (content["text"] != null &&
                              content["text"].isNotEmpty)
                            Text(
                              content["text"],
                              style: const TextStyle(fontSize: 15),
                            ),

                          const SizedBox(height: 10),

                          if (mediaItems.isNotEmpty)
                            SizedBox(
                              height: 300,
                              child: PageView.builder(
                                itemCount: mediaItems.length,
                                controller: PageController(
                                  viewportFraction: 0.95,
                                ),
                                itemBuilder: (context, i) {
                                  final item = mediaItems[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _buildMediaItem(item),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isLiked) {
                                          likedPosts.remove(index);
                                        } else {
                                          likedPosts.add(index);
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      isLiked
                                          ? Icons
                                                .thumb_up // filled icon
                                          : Icons.thumb_up_alt_outlined,
                                      color: isLiked
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${post['likes'] + (isLiked ? 1 : 0)} Likes",
                                    style: TextStyle(
                                      color: isLiked
                                          ? Colors.blue
                                          : Colors.black87,
                                      fontWeight: isLiked
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => _showCommentsDialog(post, context),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.comment_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    Text("${post['commentsCount']} Comments"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMediaItem(String item) {
    if (item.startsWith('http')) {
      return Image.network(item, fit: BoxFit.cover, width: double.infinity);
    }
    if (item.toLowerCase().endsWith('.mp4')) {
      return VideoPlayerWidget(videoPath: item);
    } else {
      return Image.file(File(item), fit: BoxFit.cover, width: double.infinity);
    }
  }

  void _showCommentsDialog(Map<String, dynamic> post, BuildContext context) {
    final comments = List<Map<String, dynamic>>.from(post["comments"] ?? []);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...comments.map((comment) {
                final user = comment["user"];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user["profileImage"]),
                  ),
                  title: Text(user["name"]),
                  subtitle: Text(comment["text"]),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
