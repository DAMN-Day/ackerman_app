import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ackerman_app/core/constants.dart';


class TachometerPainter extends CustomPainter {
  final double value; // Valor de 0.0 a 1.0

  TachometerPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = size.width * 0.8;
    
    // 1. Dibujar el fondo del arco (el rastro vacío)
    final backgroundPaint = Paint()
      ..color = DashboardColors.ghostBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,      // Empieza en 180 grados (izquierda)
      pi,      // Recorre 180 grados (media luna)
      false,
      backgroundPaint,
    );

    // 2. Dibujar el progreso (el valor real)
    final progressPaint = Paint()
      ..color = DashboardColors.neonBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3); // Efecto Neón

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * value, // El ángulo depende del valor del robot
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}