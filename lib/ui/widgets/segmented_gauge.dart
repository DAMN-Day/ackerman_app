import 'package:flutter/material.dart';
import 'package:ackerman_app/core/constants.dart';

class SegmentedGauge extends StatelessWidget {
  final double value; // 0.0 a 1.0 (ej. 0.8 para 80% de batería)
  final String label; // "BATT" o "TEMP"
  final IconData icon;

  const SegmentedGauge({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icono superior
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(height: 8),
        
        // El dibujo de los segmentos
        SizedBox(
          width: 30, // Ancho de la barra
          height: 120, // Alto de la barra
          child: CustomPaint(
            painter: _SegmentedPainter(value: value),
          ),
        ),
        
        const SizedBox(height: 8),
        // Etiqueta inferior
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SegmentedPainter extends CustomPainter {
  final double value;
  final int totalSegments = 10;

  _SegmentedPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final double segmentHeight = (size.height / totalSegments) * 0.8; // 80% del espacio es rectángulo
    final double spacing = (size.height / totalSegments) * 0.2; // 20% es espacio vacío

    for (int i = 0; i < totalSegments; i++) {
      // Calculamos la posición de cada segmento (empezando desde abajo)
      final int segmentIndex = totalSegments - 1 - i;
      final double yPos = segmentIndex * (segmentHeight + spacing);
      
      final rect = Rect.fromLTWH(0, yPos, size.width, segmentHeight);
      final RRect roundedRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

      // Determinar si el segmento está "encendido"
      final double segmentThreshold = (i + 1) / totalSegments;
      final bool isOn = value >= segmentThreshold;

      if (isOn) {
        // --- Capa de Brillo (Glow) ---
        final glowPaint = Paint()
          ..color = DashboardColors.neonBlue.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Brillo suave
        canvas.drawRRect(roundedRect, glowPaint);

        // --- Capa de Núcleo ---
        final corePaint = Paint()
          ..color = DashboardColors.neonBlue
          ..style = PaintingStyle.fill;
        canvas.drawRRect(roundedRect, corePaint);
      } else {
        // --- Segmento Apagado (Sombra) ---
        final offPaint = Paint()
          ..color = Colors.white.withOpacity(0.1) // Muy tenue
          ..style = PaintingStyle.fill;
        canvas.drawRRect(roundedRect, offPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}