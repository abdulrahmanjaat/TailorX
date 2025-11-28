import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.bottomNavigationBar,
    this.showBackButton = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry padding;
  final Widget? bottomNavigationBar;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final canPop = navigator.canPop();
    final shouldShowBack = showBackButton && canPop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title == null
          ? null
          : AppBar(
              leading: shouldShowBack
                  ? IconButton(
                      onPressed: () => navigator.maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    )
                  : null,
              automaticallyImplyLeading: false,
              title: Text(title!, style: AppTextStyles.titleLarge),
              actions: actions,
            ),
      body: SafeArea(
        child: Padding(padding: padding, child: body),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
