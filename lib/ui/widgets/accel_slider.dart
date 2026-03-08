import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AccelSlider extends StatefulWidget {
  final Function(double) onChanged;
  const AccelSlider({super.key, required this.onChanged});

  @override
  State<AccelSlider> createState() => _AccelSliderState();
}

class _AccelSliderState extends State<AccelSlider> with SingleTickerProviderStateMixin {
  double _value = 0.0; // 0.0 a 1.0
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Tiempo de regreso a 0
    );
  }

  void _resetValue() {
    // 1. Declaramos la animación como late para evitar el error de referencia
    late Animation<double> animation;

    // 2. Definimos el Tween hacia 0.0
    animation = Tween<double>(begin: _value, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _value = animation.value;
            widget.onChanged(_value);
          });
        }
      });

    // 3. ¡IMPORTANTE! Reiniciar y arrancar el controlador
    _controller.forward(from: 0.0);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _controller.stop();
        setState(() {
          // Calculamos el valor inverso (deslizar hacia arriba sube el valor)
          _value -= details.delta.dy / 200; 
          _value = _value.clamp(0.0, 1.0);
          widget.onChanged(_value);
        });
      },
      onVerticalDragEnd: (_) => _resetValue(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("FWD", style: TextStyle(color: DashboardColors.neonBlue, fontSize: 10)),
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: DashboardColors.neonBlue.withOpacity(0.3)),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Barra de progreso neón
                Container(
                  width: double.infinity,
                  height: 180 * _value,
                  decoration: BoxDecoration(
                    color: DashboardColors.neonBlue,
                    boxShadow: [
                      BoxShadow(color: DashboardColors.neonBlue, blurRadius: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}