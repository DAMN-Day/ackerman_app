import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- Importante para la orientación y el sistema
import 'package:ackerman_app/core/constants.dart';
import 'package:ackerman_app/ui/widgets/tachometer_painter.dart';

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de configurar el sistema
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Forzar Orientación Horizontal (Landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. Ocultar barras de sistema para modo "Full Screen" (Opcional pero recomendado)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MiRobotApp());
}

class MiRobotApp extends StatelessWidget {
  const MiRobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: DashboardColors.darkBackground,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _currentValue = 0.5; // Valor de prueba para el arco

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo o decoraciones adicionales
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nuestro CustomPainter
                CustomPaint(
                  size: const Size(400, 200),
                  painter: TachometerPainter(value: _currentValue),
                ),
                const SizedBox(height: 20),
                Text(
                  "${(_currentValue * 100).toInt()} %",
                  style: const TextStyle(
                    color: DashboardColors.neonBlue,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier', // Estilo digital
                  ),
                ),
              ],
            ),
          ),
          // Slider temporal en la parte inferior para probar la animación
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Slider(
                activeColor: DashboardColors.neonBlue,
                value: _currentValue,
                onChanged: (val) {
                  setState(() {
                    _currentValue = val;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}