import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roamio_frontend/theme/colors.dart';

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({super.key});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final ImagePicker _picker = ImagePicker();

  File? image;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
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
              border: Border.all(color: AppColors.borderPhoto),
            ),
            clipBehavior: Clip.antiAlias,
            child: image == null
                ? const Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedImageUpload,
                      size: 35,
                      color: AppColors.textSecondary,
                    ),
                  )
                : Image.file(image!, fit: BoxFit.cover),
          ),

          const SizedBox(height: 8),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  image == null ? "Upload Photo" : "Change Photo",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
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
