import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CountryFlag extends StatelessWidget {
  final String flag;
  final double size;
  final bool showBorder;

  const CountryFlag({
    super.key,
    required this.flag,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showBorder
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 2),
            )
          : null,
      child: Center(
        child: Text(
          flag,
          style: TextStyle(fontSize: size * 0.65),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
