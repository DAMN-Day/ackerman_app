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
  double _currentValue = 0.5;

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.darkBackground,
      body: Stack(
        children: [
          // Layout Principal
          Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double availableWidth = constraints.maxWidth;
                    double gaugeSize = availableWidth * 0.75; // Reducimos un pelo para dar aire

                    return Center(
                      child: SizedBox(
                        width: gaugeSize,
                        height: gaugeSize * 0.5,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: TachometerPainter(value: _currentValue),
                              ),
                            ),
                            Positioned(
                              bottom: 5, 
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${(_currentValue * 100).toInt()}",
                                    style: TextStyle(
                                      color: DashboardColors.neonBlue,
                                      fontSize: gaugeSize * 0.25, // Un poco más grande
                                      fontWeight: FontWeight.w900, // Más grueso
                                      letterSpacing: -2, // Números más juntos, estilo moderno
                                      shadows: [
                                        Shadow(blurRadius: 25, color: DashboardColors.neonBlue),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "POWER %",
                                    style: TextStyle(
                                      color: DashboardColors.neonBlue.withOpacity(0.8),
                                      letterSpacing: 4,
                                      fontSize: gaugeSize * 0.04,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Este SizedBox empuja todo hacia arriba para que el slider respire abajo
              const SizedBox(height: 100), 
            ],
          ),
    
          // 3. Slider de control (En la parte inferior)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Slider(
                activeColor: DashboardColors.neonBlue,
                inactiveColor: DashboardColors.ghostBlue,
                value: _currentValue,
                onChanged: (val) {
                  setState(() => _currentValue = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}