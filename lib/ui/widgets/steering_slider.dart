import 'package:flutter/material.dart';
import '../../core/constants.dart';

class SteeringSlider extends StatefulWidget {
  final Function(double) onChanged;
  const SteeringSlider({super.key, required this.onChanged});

  @override
  State<SteeringSlider> createState() => _SteeringSliderState();
}

class _SteeringSliderState extends State<SteeringSlider> with SingleTickerProviderStateMixin {
  double _value = 0.5; 
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  void _resetToCenter() {
    // 1. Declaramos la variable primero sin asignarle valor
    late Animation<double> animation; 
    
    // 2. Ahora sí la definimos
    animation = Tween<double>(begin: _value, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    )..addListener(() {
        if (mounted) {
          setState(() {
            // Ahora 'animation' ya existe para el compilador
            _value = animation.value; 
            widget.onChanged(_value);
          });
        }
      });
      
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "STEERING", 
          style: TextStyle(
            color: DashboardColors.neonBlue.withOpacity(0.7), 
            fontSize: 10, 
            letterSpacing: 2
          )
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 220, // Un poco más ancho para las letras
          child: Row(
            children: [
              // Etiqueta Izquierda
              Text("L", style: TextStyle(color: DashboardColors.neonBlue, fontWeight: FontWeight.bold)),
              
              // El Slider
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    activeTrackColor: DashboardColors.neonBlue,
                    inactiveTrackColor: DashboardColors.ghostBlue,
                    thumbColor: DashboardColors.neonBlue,
                  ),
                  child: Slider(
                    value: _value,
                    onChanged: (val) {
                      _controller.stop();
                      setState(() {
                        _value = val;
                        widget.onChanged(_value);
                      });
                    },
                    onChangeEnd: (_) => _resetToCenter(),
                  ),
                ),
              ),
              
              // Etiqueta Derecha
              Text("R", style: TextStyle(color: DashboardColors.neonBlue, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        // Marca visual del centro
        Container(
          width: 2,
          height: 8,
          color: Colors.white24,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}