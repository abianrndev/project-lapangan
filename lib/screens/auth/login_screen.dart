import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'test login',
                style: AppTextStyles.headerLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'tes admin',
                onPressed: () => context.go('/admin'),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'tes user',
                onPressed: () => context.go('/user'),
                isSecondary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
