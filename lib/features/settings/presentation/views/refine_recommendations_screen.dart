import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/auth/domain/entities/user_profile.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';

/// Refine recommendations — select/deselect interest topics.
class RefineRecommendationsScreen extends ConsumerStatefulWidget {
  const RefineRecommendationsScreen({super.key});

  @override
  ConsumerState<RefineRecommendationsScreen> createState() =>
      _RefineRecommendationsScreenState();
}

class _RefineRecommendationsScreenState
    extends ConsumerState<RefineRecommendationsScreen> {
  static const _allTopics = [
    'Travel',
    'Food',
    'Fashion',
    'Home Decor',
    'Art',
    'Animals',
    'Photography',
    'Technology',
    'Fitness',
    'DIY',
    'Nature',
    'Music',
    'Architecture',
    'Cars',
    'Gaming',
    'Movies',
    'Books',
    'Beauty',
  ];

  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final ds = ref.read(userProfileDatasourceProvider);
    _selected = ds.getSelectedTopics().toSet();
  }

  Future<void> _save() async {
    final ds = ref.read(userProfileDatasourceProvider);
    final profile = ds.getProfile();
    final updated = (profile ??
            const UserProfile())
        .copyWith(selectedTopics: _selected.toList());
    await ds.saveProfile(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferences saved'),
          backgroundColor: AppColors.surfaceVariantDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppBorders.md),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimaryDark,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Refine recommendations',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.pinterestRed,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select topics you are interested in to get better recommendations.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space5),
            Expanded(
              child: Wrap(
                spacing: AppSpacing.space3,
                runSpacing: AppSpacing.space3,
                children: _allTopics.map((topic) {
                  final isSelected = _selected.contains(topic);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(topic);
                        } else {
                          _selected.add(topic);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space5,
                        vertical: AppSpacing.space3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.pinterestRed
                            : AppColors.surfaceVariantDark,
                        borderRadius: AppBorders.full,
                      ),
                      child: Text(
                        topic,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
