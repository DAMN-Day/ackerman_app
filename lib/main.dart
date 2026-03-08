import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ackerman_app/core/constants.dart';
import 'package:ackerman_app/ui/widgets/tachometer_painter.dart';
import 'package:ackerman_app/ui/widgets/segmented_gauge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
  double _batteryLevel = 0.8;

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para cálculos precisos
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DashboardColors.darkBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye arriba, centro y abajo
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. EL ARCO (Tacómetro)
            SizedBox(
              width: size.width * 0.5,
              height: size.width * 0.25,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TachometerPainter(value: _currentValue),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(_currentValue * 100).toInt()}",
                          style: TextStyle(
                            color: DashboardColors.neonBlue,
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(blurRadius: 25, color: DashboardColors.neonBlue),
                            ],
                          ),
                        ),
                        Text(
                          "POWER %",
                          style: TextStyle(
                            color: DashboardColors.neonBlue,
                            letterSpacing: 4,
                            fontSize: size.width * 0.015,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            
            // 2. BATERÍA (Estilo Honda)
            Center( // Primer nivel de centrado
              child: SizedBox(
                width: 250, // Coincide con el width que definimos en el widget
                child: SegmentedGauge(value: _batteryLevel),
              ),
            ),

            // 3. SLIDER (Control)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Slider(
                activeColor: DashboardColors.neonBlue,
                inactiveColor: DashboardColors.ghostBlue,
                value: _currentValue,
                onChanged: (val) {
                  setState(() => _currentValue = val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}