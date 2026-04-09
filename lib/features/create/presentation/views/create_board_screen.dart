import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/features/create/domain/entities/board.dart';
import 'package:pinterest/features/create/presentation/providers/create_providers.dart';

/// Screen for creating a new Board.
class CreateBoardScreen extends ConsumerStatefulWidget {
  const CreateBoardScreen({super.key});

  @override
  ConsumerState<CreateBoardScreen> createState() => _CreateBoardScreenState();
}

class _CreateBoardScreenState extends ConsumerState<CreateBoardScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _coverImagePath;
  bool _isSaving = false;
  bool _isSecret = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _coverImagePath = image.path);
    }
  }

  Future<void> _saveBoard() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      AppToast.error(context, message: 'Please enter a board name');
      return;
    }

    setState(() => _isSaving = true);

    final board = Board(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descriptionController.text.trim(),
      coverImagePath: _coverImagePath ?? '',
      createdAt: DateTime.now(),
    );

    await ref.read(boardsProvider.notifier).addBoard(board);

    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.success(context, message: 'Board created!');
      Navigator.of(context).pop();
    }
  }

  bool get _canSave => _nameController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(),
            SizedBox(height: AppSpacing.space7),
            _buildNameField(),
            Divider(color: AppColors.dividerDark, height: AppSpacing.space7),
            _buildDescriptionField(),
            Divider(color: AppColors.dividerDark, height: AppSpacing.space7),
            _buildSecretToggle(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: AppColors.textPrimaryDark,
          size: 24.sp,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        'Create Board',
        style: AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.space4),
          child: _buildCreateButton(),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: _canSave && !_isSaving ? _saveBoard : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: _canSave
              ? AppColors.pinterestRed
              : AppColors.surfaceVariantDark,
          borderRadius: AppBorders.full,
        ),
        child: _isSaving
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.w,
                ),
              )
            : Text(
                'Create',
                style: AppTypography.labelMedium.copyWith(
                  color: _canSave ? Colors.white : AppColors.textTertiaryDark,
                ),
              ),
      ),
    );
  }

  Widget _buildCoverImage() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: _coverImagePath != null
          ? ClipRRect(
              borderRadius: AppBorders.lg,
              child: Image.file(
                File(_coverImagePath!),
                width: double.infinity,
                height: 180.h,
                fit: BoxFit.cover,
              ),
            )
          : Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantDark,
                borderRadius: AppBorders.lg,
                border: Border.all(
                  color: AppColors.dividerDark,
                  width: 1.5.w,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.textSecondaryDark,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space3),
                  Text(
                    'Add cover image',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space1),
                  Text(
                    'Optional',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Board name',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        SizedBox(height: AppSpacing.space2),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantDark,
            borderRadius: AppBorders.md,
          ),
          child: TextField(
            controller: _nameController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
            decoration: InputDecoration(
              hintText: 'Like "Places to Go" or "Recipes"',
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiaryDark,
              ),
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        SizedBox(height: AppSpacing.space2),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.space5,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantDark,
            borderRadius: AppBorders.md,
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
            decoration: InputDecoration(
              hintText: 'What is your board about?',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiaryDark,
              ),
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecretToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keep this board secret',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              SizedBox(height: AppSpacing.space1),
              Text(
                'Only you and collaborators can see it',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: _isSecret,
          onChanged: (v) => setState(() => _isSecret = v),
          activeColor: AppColors.pinterestRed,
          inactiveTrackColor: AppColors.surfaceVariantDark,
        ),
      ],
    );
  }
}
