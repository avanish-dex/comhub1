import 'package:comhub1/core/common/error_text.dart';
import 'package:comhub1/core/common/loader.dart';
import 'package:comhub1/core/common/post_card.dart';
import 'package:comhub1/features/auth/controller/auth_controller.dart';
import 'package:comhub1/features/community/controller/community_controller.dart';
import 'package:comhub1/features/posts/controller/post_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    if (!isGuest) {
      return ref.watch(userCommunitiesProvider).when(
          data: (communties) => ref.watch(userPostsProvider(communties)).when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final post = data[index];
                    return PostCard(post: post);
                  },
                );
              },
              error: ((error, stackTrace) =>
                  ErrorText(error: error.toString())),
              loading: () => const Loader()),
          error: ((error, stackTrace) => ErrorText(error: error.toString())),
          loading: () => const Loader());
    }
    return ref.watch(userCommunitiesProvider).when(
        data: (communties) => ref.watch(guestPostsProvider).when(
            data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  final post = data[index];
                  return PostCard(post: post);
                },
              );
            },
            error: ((error, stackTrace) => ErrorText(error: error.toString())),
            loading: () => const Loader()),
        error: ((error, stackTrace) => ErrorText(error: error.toString())),
        loading: () => const Loader());
  }
}
