import 'package:flutter/material.dart';

import 'app_colors.dart';

/// App-wide type scale. No font family is specified, so Android uses its system font.
abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 36,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.1,
    color: AppColors.primaryText,
  );

  static const headline = TextStyle(
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.primaryText,
  );

  static const title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
    color: AppColors.primaryText,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static const label = TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
  );
}
