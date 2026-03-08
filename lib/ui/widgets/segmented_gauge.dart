import 'package:flutter/material.dart';
import 'package:ackerman_app/core/constants.dart';


class SegmentedGauge extends StatelessWidget {
  final double value; // 0.0 a 1.0 (ej. 0.8 para 80% de batería)

  const SegmentedGauge({
    super.key,
    required this.value,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center, // <--- CAMBIA ESTO (estaba en .start)
      children: [
        // Fila para el icono y la etiqueta
        Row(
          mainAxisSize: MainAxisSize.min, // <--- AÑADE ESTO para que no ocupe todo el ancho
          children: [
            Icon(Icons.battery_charging_full_rounded, color: DashboardColors.neonBlue, size: 16),
            const SizedBox(width: 5),
            Text(
              "BATTERY",
              style: TextStyle(
                color: DashboardColors.neonBlue,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // El dibujo de la barra
        SizedBox(
          width: 250, 
          height: 60, 
          child: CustomPaint(
            painter: _HondaFuelGaugePainter(value: value),
          ),
        ),
      ],
    );
  }
}

class _HondaFuelGaugePainter extends CustomPainter {
  final double value;
  final int totalSegments = 10; // 10 segmentos de batería

  _HondaFuelGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    // Definimos la línea de base (el "rail")
    final double baselineY = size.height * 0.7; // Posición vertical de la línea
    final double paddingX = 15; // Espacio para las letras 'E' y 'F'
    final double barWidth = size.width - (paddingX * 2);
    
    // --- Capa 1: Dibujar la línea de base ---
    final baseLinePaint = Paint()
      ..color = DashboardColors.neonBlue.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(Offset(paddingX, baselineY), Offset(paddingX + barWidth, baselineY), baseLinePaint);

    // --- Capa 2: Dibujar los Ticks (marcas de escala) y Letras (E/F) ---
    final tickPaint = Paint()
      ..color = DashboardColors.neonBlue.withOpacity(0.6)
      ..strokeWidth = 1.5;

    // Ticks en los extremos y medio
    _drawTick(canvas, Offset(paddingX, baselineY), tickPaint); // En 'E'
    _drawTick(canvas, Offset(paddingX + barWidth / 2, baselineY), tickPaint); // Medio
    _drawTick(canvas, Offset(paddingX + barWidth, baselineY), tickPaint); // En 'F'

    // Dibujar 'E' y 'F'
    _drawLabel(canvas, "E", Offset(paddingX - 10, baselineY), isStart: true);
    _drawLabel(canvas, "F", Offset(paddingX + barWidth + 10, baselineY));

    // --- Capa 3: Dibujar los Segmentos de Batería (Nivel) ---
    final double segmentWidth = (barWidth / totalSegments) * 0.9; // 90% de espacio es rectángulo
    final double segmentSpacing = (barWidth / totalSegments) * 0.1; // 10% es espacio vacío
    
    for (int i = 0; i < totalSegments; i++) {
      // Determinar si el segmento está "encendido"
      final double segmentThreshold = (i + 1) / totalSegments;
      final bool isOn = value >= segmentThreshold;

      final double xPos = paddingX + (i * (segmentWidth + segmentSpacing));
      
      final rect = Rect.fromLTWH(xPos, baselineY - 15, segmentWidth, 15); // Segmentos hacia arriba
      final RRect roundedRect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

      if (isOn) {
        // --- Capa de Brillo (Glow) para los segmentos ---
        final glowPaint = Paint()
          ..color = DashboardColors.neonBlue.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // Brillo neón
        canvas.drawRRect(roundedRect, glowPaint);

        // --- Capa de Núcleo (Sólido) ---
        final corePaint = Paint()
          ..color = DashboardColors.neonBlue
          ..style = PaintingStyle.fill;
        canvas.drawRRect(roundedRect, corePaint);
      }
    }
  }

  // Método auxiliar para dibujar ticks
  void _drawTick(Canvas canvas, Offset position, Paint paint) {
    canvas.drawLine(Offset(position.dx, position.dy - 8), Offset(position.dx, position.dy + 4), paint);
  }

  // Método auxiliar para dibujar las letras E/F
  void _drawLabel(Canvas canvas, String label, Offset position, {bool isStart = false}) {
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: DashboardColors.neonBlue,
        fontFamily: 'Courier', // Estilo digital como en el Civic
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Ajuste de posición para centrar el texto en el tick
    final textOffset = isStart 
      ? Offset(position.dx - textPainter.width, position.dy - textPainter.height / 2)
      : Offset(position.dx, position.dy - textPainter.height / 2);

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant _HondaFuelGaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}