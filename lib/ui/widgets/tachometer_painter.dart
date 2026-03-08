import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ackerman_app/core/constants.dart';


class TachometerPainter extends CustomPainter {
  final double value; // Valor de 0.0 a 1.0

  TachometerPainter({required this.value});

@override
void paint(Canvas canvas, Size size) {
  final center = Offset(size.width / 2, size.height);
  final radius = size.width * 0.45;

  // --- 1. Fondo del arco ---
  final bgPaint = Paint()
    ..color = DashboardColors.ghostBlue
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, bgPaint);

  // --- 2. Graduaciones (Ticks) ---
  final tickPaint = Paint()
    ..color = Colors.white.withOpacity(0.5)
    ..strokeWidth = 2;

  for (int i = 0; i <= 10; i++) {
    // Calculamos el ángulo para cada marca (de 180 a 360 grados)
    double angle = pi + (i * pi / 10);
    
    // Punto inicial (cerca del borde exterior)
    Offset start = Offset(
      center.dx + (radius - 5) * cos(angle),
      center.dy + (radius - 5) * sin(angle),
    );
    // Punto final (hacia adentro)
    Offset end = Offset(
      center.dx + (radius - 15) * cos(angle),
      center.dy + (radius - 15) * sin(angle),
    );
    canvas.drawLine(start, end, tickPaint);
  }

  // --- 3. Progreso Neón ---
  if (value > 0) {
    final progressPaint = Paint()
      ..color = DashboardColors.neonBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12); // Brillo neón

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * value,
      false,
      progressPaint,
    );
  }
}
@override
  bool shouldRepaint(covariant TachometerPainter oldDelegate) {
    // Solo repinta si el valor cambia para ahorrar batería
    return oldDelegate.value != value;
  }
}