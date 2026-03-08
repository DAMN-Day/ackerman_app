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


  // --- 3. Arco de Progreso con Brillo Triple (Neon Pro) ---
  if (value > 0) {
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    final double sweepAngle = pi * value;

    // CAPA 1: El Aura (Gran resplandor de fondo)
    final auraPaint = Paint()
      ..color = DashboardColors.neonBlue.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 35 // Muy ancha para el brillo exterior
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawArc(arcRect, pi, sweepAngle, false, auraPaint);

    // CAPA 2: El Resplandor (El brillo que "quema")
    final glowPaint = Paint()
      ..color = DashboardColors.neonBlue.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    
    canvas.drawArc(arcRect, pi, sweepAngle, false, glowPaint);


    // Un segundo core encima del blanco con el color neón puro
    final neonCorePaint = Paint()
      ..color = DashboardColors.neonBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;


    canvas.drawArc(arcRect, pi, sweepAngle, false, neonCorePaint);
  }

  // --- 4. Dibujar Números (0 a 7) ---
  final textPainter = TextPainter(textDirection: TextDirection.ltr);

  for (int i = 0; i <= 7; i++) {
    // Calculamos el ángulo para cada número (de pi a 2*pi)
    double angle = pi + (i * pi / 7);
    
    // Posicionamos los números un poco más afuera del radio del arco
    double textRadius = radius + 25; 
    
    Offset textPos = Offset(
      center.dx + textRadius * cos(angle),
      center.dy + textRadius * sin(angle),
    );

    textPainter.text = TextSpan(
      text: "$i",
      style: TextStyle(
        color: Colors.white.withOpacity(0.8),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'Courier',
      ),
    );
    
    textPainter.layout();
    // Centramos el texto en su posición calculada
    textPainter.paint(canvas, Offset(textPos.dx - textPainter.width / 2, textPos.dy - textPainter.height / 2));
  }

}

@override
  bool shouldRepaint(covariant TachometerPainter oldDelegate) {
    // Solo repinta si el valor cambia para ahorrar batería
    return oldDelegate.value != value;
  }
}