import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/constants/app_constants.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_card.dart';

class MasonryFeed extends StatefulWidget {
  const MasonryFeed({
    super.key,
    required this.photos,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<Photo> photos;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  State<MasonryFeed> createState() => _MasonryFeedState();
}

class _MasonryFeedState extends State<MasonryFeed> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll * AppConstants.paginationScrollThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: Colors.white,
      backgroundColor: Colors.black,
      child: MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: AppConstants.gridColumns,
        mainAxisSpacing: AppConstants.gridSpacing,
        crossAxisSpacing: AppConstants.gridSpacing,
        padding: EdgeInsets.all(4.w),
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return PinCard(photo: widget.photos[index]);
        },
      ),
    );
  }
}
