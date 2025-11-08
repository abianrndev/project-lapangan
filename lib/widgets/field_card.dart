import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../models/field.dart';
import 'custom_button.dart';

class FieldCard extends StatelessWidget {
  final Field field;
  final VoidCallback onBook;
  final VoidCallback? onEdit;

  const FieldCard({
    Key? key,
    required this.field,
    required this.onBook,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              field.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColors.surface,
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(field.name, style: AppTextStyles.headerMedium),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                        color: AppColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(field.description, style: AppTextStyles.bodyText),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${field.price.toStringAsFixed(0)}',
                      style: AppTextStyles.headerMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: field.isAvailable
                            ? AppColors.secondary.withOpacity(0.1)
                            : AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        field.isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                        style: AppTextStyles.bodyText.copyWith(
                          color: field.isAvailable
                              ? AppColors.secondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Pesan Sekarang',
                  onPressed: onBook,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
