import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AccelSlider extends StatefulWidget {
  final Function(double) onChanged;
  const AccelSlider({super.key, required this.onChanged});

  @override
  State<AccelSlider> createState() => _AccelSliderState();
}

class _AccelSliderState extends State<AccelSlider> with SingleTickerProviderStateMixin {
  // Ahora el rango es de -1.0 (Reversa) a 1.0 (Adelante)
  double _value = 0.0; 
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _resetValue() {
    final Animation<double> animation = Tween<double>(
      begin: _value, 
      end: 0.0
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));

    _controller.addListener(() {
      setState(() {
        _value = animation.value;
      });
      widget.onChanged(_value);
    });

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("FWD", style: TextStyle(color: Colors.white38, fontSize: 9)),
        const SizedBox(height: 8),
        GestureDetector(
          onVerticalDragUpdate: (details) {
            _controller.stop();
            _controller.removeListener(() {}); // Limpiar listeners previos
            setState(() {
              // Sensibilidad del arrastre (puedes ajustar el 200)
              _value -= details.delta.dy / 100; 
              _value = _value.clamp(-1.0, 1.0);
            });
            widget.onChanged(_value);
          },
          onVerticalDragEnd: (_) => _resetValue(),
          child: Container(
            width: 60,
            height: 240, // Aumentamos el tamaño para que luzca la reversa
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashboardColors.neonBlue.withOpacity(0.2)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Línea central de referencia (EL CERO)
                Container(
                  width: 40,
                  height: 2,
                  color: Colors.white24,
                ),
                const Positioned(
                  right: 5,
                  child: Text("0", style: TextStyle(color: Colors.white24, fontSize: 10)),
                ),

                // 2. El "Track" o camino visual
                Container(
                  width: 4,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 3. El Indicador Neón (El que se mueve)
                // Usamos Positioned para moverlo según el valor de _value
                Positioned(
                  bottom: 120 + (_value * 100) - 15, // Mapeo visual al centro
                  child: Container(
                    width: 45,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _value >= 0 ? DashboardColors.neonBlue : Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: (_value >= 0 ? DashboardColors.neonBlue : Colors.redAccent).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: const Icon(Icons.unfold_more, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("REV", style: TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}