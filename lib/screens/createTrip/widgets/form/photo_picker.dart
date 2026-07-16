import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roamio_frontend/theme/colors.dart';

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({
    super.key,
    this.image,
    this.onChanged,
  });

  final File? image;
  final ValueChanged<File?>? onChanged;

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    final selectedImage = File(picked.path);

    widget.onChanged?.call(selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.bgPhoto,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderPhoto,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.image == null
                ? const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedImageUpload,
                      size: 35,
                      color: AppColors.textSecondary,
                    ),
                  )
                : Image.file(
                    widget.image!,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.image == null
                      ? "Upload Photo"
                      : "Change Photo",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "(Optional)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.btnPrimary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}