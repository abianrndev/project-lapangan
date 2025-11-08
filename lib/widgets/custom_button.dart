import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSecondary;
  final bool isFullWidth;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isFullWidth = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : AppColors.primary,
          foregroundColor: isSecondary ? AppColors.primary : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isSecondary
                ? const BorderSide(color: AppColors.primary)
                : BorderSide.none,
          ),
          elevation: isSecondary ? 0 : 2,
        ),
        child: Text(
          text,
          style: AppTextStyles.buttonText.copyWith(
            color: isSecondary ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
