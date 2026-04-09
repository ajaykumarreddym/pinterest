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
import 'package:pinterest/features/create/domain/entities/collage.dart';
import 'package:pinterest/features/create/presentation/providers/create_providers.dart';

/// Screen for creating a Collage from multiple gallery images.
class CreateCollageScreen extends ConsumerStatefulWidget {
  const CreateCollageScreen({super.key});

  @override
  ConsumerState<CreateCollageScreen> createState() =>
      _CreateCollageScreenState();
}

class _CreateCollageScreenState extends ConsumerState<CreateCollageScreen> {
  final _titleController = TextEditingController();
  final List<String> _imagePaths = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (images.isNotEmpty) {
      setState(() {
        _imagePaths.addAll(images.map((img) => img.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  Future<void> _saveCollage() async {
    final title = _titleController.text.trim();
    if (_imagePaths.length < 2) {
      AppToast.error(context, message: 'Select at least 2 images');
      return;
    }
    if (title.isEmpty) {
      AppToast.error(context, message: 'Please enter a title');
      return;
    }

    setState(() => _isSaving = true);

    final collage = Collage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      imagePaths: List.unmodifiable(_imagePaths),
      createdAt: DateTime.now(),
    );

    await ref.read(collagesProvider.notifier).addCollage(collage);

    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.success(context, message: 'Collage created!');
      Navigator.of(context).pop();
    }
  }

  bool get _canSave =>
      _imagePaths.length >= 2 && _titleController.text.trim().isNotEmpty;

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
            _buildTitleField(),
            SizedBox(height: AppSpacing.space5),
            if (_imagePaths.isNotEmpty) ...[
              _buildImageGrid(),
              SizedBox(height: AppSpacing.space4),
              _buildImageCount(),
              SizedBox(height: AppSpacing.space5),
            ],
            _buildAddImagesButton(),
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
        'Create Collage',
        style: AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.space4),
          child: _buildSaveButton(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _canSave && !_isSaving ? _saveCollage : null,
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
                'Save',
                style: AppTypography.labelMedium.copyWith(
                  color: _canSave ? Colors.white : AppColors.textTertiaryDark,
                ),
              ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: AppBorders.md,
      ),
      child: TextField(
        controller: _titleController,
        onChanged: (_) => setState(() {}),
        style: AppTypography.h3.copyWith(color: AppColors.textPrimaryDark),
        decoration: InputDecoration(
          hintText: 'Add a title',
          hintStyle: AppTypography.h3.copyWith(
            color: AppColors.textTertiaryDark,
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.space2,
        mainAxisSpacing: AppSpacing.space2,
      ),
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: AppBorders.md,
              child: Image.file(
                File(_imagePaths[index]),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: AppSpacing.space2,
              right: AppSpacing.space2,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.space2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageCount() {
    return Text(
      '${_imagePaths.length} images selected',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.textTertiaryDark,
      ),
    );
  }

  Widget _buildAddImagesButton() {
    final isEmpty = _imagePaths.isEmpty;

    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        height: isEmpty ? 200.h : 56.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantDark,
          borderRadius: AppBorders.lg,
          border: Border.all(color: AppColors.dividerDark, width: 1.5.w),
        ),
        child: isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.textSecondaryDark,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space4),
                  Text(
                    'Select at least 2 images',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space1),
                  Text(
                    'From your gallery',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: AppColors.textSecondaryDark,
                    size: 20.sp,
                  ),
                  SizedBox(width: AppSpacing.space3),
                  Text(
                    'Add more images',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
