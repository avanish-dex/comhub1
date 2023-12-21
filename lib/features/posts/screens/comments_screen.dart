import 'package:comhub1/core/common/error_text.dart';
import 'package:comhub1/core/common/loader.dart';
import 'package:comhub1/core/common/post_card.dart';
import 'package:comhub1/features/auth/controller/auth_controller.dart';
import 'package:comhub1/features/posts/controller/post_controller.dart';
import 'package:comhub1/features/posts/widgets/comment_card.dart';
import 'package:comhub1/models/post_model.dart';
import 'package:comhub1/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context, text: commentController.text.trim(), post: post);
    setState(() {
      commentController.text = ' ';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return FutureBuilder<Post>(
      future: ref.read(getPostByIdProvider(widget.postId).future),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        } else if (snapshot.hasError) {
          return ErrorText(error: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          // Handle the case where the post data is not available.
          return const Text('Post not found.');
        } else {
          final data = snapshot.data; // The post data is available here.
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  PostCard(post: data!),
                  if (!isGuest)
                    Responsive(
                      child: TextField(
                        onSubmitted: (val) => addComment(data),
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Comment your thoughts',
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ref.watch(getPostCommentsProvider(widget.postId)).when(
                        data: (data) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              final comment = data[index];
                              return CommentCard(comment: comment);
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return ErrorText(error: error.toString());
                        },
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
