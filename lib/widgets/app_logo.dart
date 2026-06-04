import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/theme.dart';

/// Hala Dental logo widget.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 80, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'HALA DENTAL',
            style: TextStyle(
              fontSize: size > 60 ? 28 : 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'C L I N I C',
            style: TextStyle(
              fontSize: size > 60 ? 14 : 11,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 4,
            ),
          ),
        ],
      ],
    );
  }
}
