import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// Handles camera/gallery image picking for visual search.
///
/// Shows a bottom sheet letting the user choose between camera and gallery,
/// picks the image, and returns the file path.
class CameraSearchService {
  CameraSearchService._();

  static final _picker = ImagePicker();

  /// Shows a source picker bottom sheet and picks an image.
  /// Returns the file path of the picked image, or null if cancelled.
  static Future<String?> pickSearchImage(BuildContext context) async {
    final source = await _showSourcePicker(context);
    if (source == null) return null;

    final image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    return image?.path;
  }

  static Future<ImageSource?> _showSourcePicker(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppBorders.bottomSheet,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppSpacing.space5),
              Text(
                'Search with your camera',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.space7),
              _SourceOption(
                icon: Icons.camera_alt,
                label: 'Take a photo',
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              _SourceOption(
                icon: Icons.photo_library,
                label: 'Choose from gallery',
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              SizedBox(height: AppSpacing.space5),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textPrimaryDark,
              size: 24.sp,
            ),
            SizedBox(width: AppSpacing.space5),
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen showing visual search results for a camera-picked image.
class CameraSearchResultsScreen extends StatelessWidget {
  const CameraSearchResultsScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: EdgeInsets.all(AppSpacing.space4),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textPrimaryDark,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space4),
                  Text(
                    'Visual search',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            // Picked image preview
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: ClipRRect(
                borderRadius: AppBorders.lg,
                child: Image.file(
                  File(imagePath),
                  height: 250.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space5),
            // Info text
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.space8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_search,
                        color: AppColors.textTertiaryDark,
                        size: 48.sp,
                      ),
                      SizedBox(height: AppSpacing.space4),
                      Text(
                        'Visual search is powered by image recognition',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      SizedBox(height: AppSpacing.space3),
                      Text(
                        'Try searching with keywords for best results',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
