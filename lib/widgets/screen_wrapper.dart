import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ScreenWrapper extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final List<Widget>? actions;

  const ScreenWrapper({
    Key? key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: actions,
      ),
      body: body,
    );
  }
}
