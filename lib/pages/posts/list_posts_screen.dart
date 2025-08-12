import 'package:flutter/material.dart';
import 'package:flutter_api/models/posts_model.dart';
import 'package:flutter_api/services/posts_service.dart';

class ListPostScreen extends StatefulWidget {
  const ListPostScreen({super.key});

  @override
  State<ListPostScreen> createState() => _ListPostScreenState();
}

class _ListPostScreenState extends State<ListPostScreen> {
  late Future<PostModel> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = PostsService.listPost();
  }

  void _refreshPosts() {
    setState(() {
      _futurePosts = PostsService.listPost();
    });
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate != null) {
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        actions: [
          IconButton(onPressed: _refreshPosts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<PostModel>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final posts = snapshot.data?.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts found'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: post.foto != null && post.foto!.isNotEmpty
                      ? Image.network(
                          'http://127.0.0.1:8000/storage/${post.foto!}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        )
                      : const Icon(Icons.article),
                  title: Text(post.title ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.content != null && post.content!.isNotEmpty)
                        Text(
                          post.content!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        '${_formatDate(post.createdAt?.toIso8601String())} • ${post.status == 1 ? "Published" : "Draft"}',
                        style: TextStyle(
                          color: post.status == 1
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text('#${post.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
