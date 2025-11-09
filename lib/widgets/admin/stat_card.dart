import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/text_styles.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? AppColors.primary,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(Icons.more_vert, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: AppTextStyles.headerLarge),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
