import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VideoPreviewSkeleton extends StatelessWidget {
  const VideoPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail (image)
        Container(
          height: MediaQuery.of(context).size.width * 9 / 16,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 10),
        // Title
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 6),
        // Subtitle
        Container(
          height: 14,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }
}

class VideoCardSkeleton extends StatelessWidget {
  final int count;
  const VideoCardSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(
          count,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Shimmer.fromColors(
              baseColor: theme.cardColor.withValues(alpha: 0.2),
              highlightColor: theme.highlightColor.withValues(alpha: 0.2),
              child: const VideoPreviewSkeleton(),
            ),
          ),
        ),
      ),
    );
  }
}
