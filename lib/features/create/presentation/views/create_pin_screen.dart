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
import 'package:pinterest/features/create/domain/entities/created_pin.dart';
import 'package:pinterest/features/create/presentation/providers/create_providers.dart';

/// Screen for creating a new Pin from the user's gallery.
class CreatePinScreen extends ConsumerStatefulWidget {
  const CreatePinScreen({super.key});

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedImagePath;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
    }
  }

  Future<void> _savePin() async {
    final title = _titleController.text.trim();
    if (_selectedImagePath == null) {
      AppToast.error(context, message: 'Please select an image');
      return;
    }
    if (title.isEmpty) {
      AppToast.error(context, message: 'Please enter a title');
      return;
    }

    setState(() => _isSaving = true);

    final pin = CreatedPin(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: _selectedImagePath!,
      title: title,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ref.read(createdPinsProvider.notifier).addPin(pin);

    if (mounted) {
      setState(() => _isSaving = false);
      AppToast.success(context, message: 'Pin created!');
      Navigator.of(context).pop();
    }
  }

  bool get _canSave =>
      _selectedImagePath != null && _titleController.text.trim().isNotEmpty;

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
            _buildImagePicker(),
            SizedBox(height: AppSpacing.space7),
            _buildTitleField(),
            Divider(color: AppColors.dividerDark, height: AppSpacing.space3),
            SizedBox(height: AppSpacing.space3),
            _buildDescriptionField(),
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
        'Create Pin',
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
      onTap: _canSave && !_isSaving ? _savePin : null,
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

  Widget _buildImagePicker() {
    if (_selectedImagePath != null) {
      return GestureDetector(
        onTap: _pickImage,
        child: ClipRRect(
          borderRadius: AppBorders.lg,
          child: Image.file(
            File(_selectedImagePath!),
            width: double.infinity,
            height: 320.h,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 320.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantDark,
          borderRadius: AppBorders.lg,
          border: Border.all(color: AppColors.dividerDark, width: 1.5.w),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.textSecondaryDark,
                size: 28.sp,
              ),
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              'Tap to select an image',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space2),
            Text(
              'From your gallery',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiaryDark,
              ),
            ),
          ],
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

  Widget _buildDescriptionField() {
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
        controller: _descriptionController,
        maxLines: 3,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        decoration: InputDecoration(
          hintText: 'Tell everyone what your Pin is about',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiaryDark,
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
        ),
      ),
    );
  }
}