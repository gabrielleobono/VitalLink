import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Logo officiel VitalLink extrait fidèlement de la maquette Figma :
/// Conteneur rouge arrondi, goutte blanche pointée et croix rouge médicale centrée.
class VitalLinkLogo extends StatelessWidget {
  final double size;

  const VitalLinkLogo({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _FigmaVitalLinkLogoPainter(crossColor: AppColors.primary),
      ),
    );
  }
}

class _FigmaVitalLinkLogoPainter extends CustomPainter {
  final Color crossColor;

  const _FigmaVitalLinkLogoPainter({required this.crossColor});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64.0;

    // 1. Goutte blanche fidèle au tracé Figma (repère normalisé 64x64)
    final dropPath = Path()
      ..moveTo(32 * scale, 14 * scale)
      ..cubicTo(
        32 * scale,
        14 * scale,
        46 * scale,
        29 * scale,
        46 * scale,
        39 * scale,
      )
      ..cubicTo(
        46 * scale,
        47 * scale,
        39.7 * scale,
        52 * scale,
        32 * scale,
        52 * scale,
      )
      ..cubicTo(
        24.3 * scale,
        52 * scale,
        18 * scale,
        47 * scale,
        18 * scale,
        39 * scale,
      )
      ..cubicTo(
        18 * scale,
        29 * scale,
        32 * scale,
        14 * scale,
        32 * scale,
        14 * scale,
      )
      ..close();

    final dropPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(dropPath, dropPaint);

    // 2. Croix rouge médicale épaisse, parfaitement centrée dans le corps de la goutte
    final crossPaint = Paint()
      ..color = crossColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cornerRadius = Radius.circular(1.2 * scale);

    // Barre verticale (largeur 5, hauteur 16, centrée sur x=32, y=35)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(32 * scale, 35 * scale),
          width: 5 * scale,
          height: 16 * scale,
        ),
        cornerRadius,
      ),
      crossPaint,
    );

    // Barre horizontale (largeur 16, hauteur 5, centrée sur x=32, y=35)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(32 * scale, 35 * scale),
          width: 16 * scale,
          height: 5 * scale,
        ),
        cornerRadius,
      ),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
