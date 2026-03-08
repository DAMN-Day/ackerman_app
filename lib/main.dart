import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ackerman_app/core/constants.dart';
import 'package:ackerman_app/ui/widgets/tachometer_painter.dart';
import 'package:ackerman_app/ui/widgets/segmented_gauge.dart';
import 'package:ackerman_app/ui/widgets/accel_slider.dart';
import 'package:ackerman_app/ui/widgets/steering_slider.dart';
import 'package:ackerman_app/ui/widgets/connect_button.dart';

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
  double _currentValue = 0.0; // Empezamos en 0 para el efecto "muelle"
  double _batteryLevel = 0.8;
  double _steeringValue = 0.5;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  void _handleConnect() async {
    if (_connectionStatus == ConnectionStatus.disconnected) {
      setState(() => _connectionStatus = ConnectionStatus.connecting);
      
      // Simulamos una espera de búsqueda de 2 segundos
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() => _connectionStatus = ConnectionStatus.connected);
    } else {
      setState(() => _connectionStatus = ConnectionStatus.disconnected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DashboardColors.darkBackground,
      body: Stack(
        children: [
          // 1. CAPA CENTRAL: ARCO Y BATERÍA
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // EL ARCO
                SizedBox(
                  width: size.width * 0.45,
                  height: size.width * 0.22,
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
                                fontSize: size.width * 0.07,
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
                                fontSize: size.width * 0.012,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // LA BATERÍA
                SizedBox(
                  width: 250,
                  child: SegmentedGauge(value: _batteryLevel),
                ),
                // Espacio inferior para equilibrar
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 2. CONTROL IZQUIERDO: ACELERACIÓN (Vertical c/ Retorno)
          Positioned(
            left: 50,
            bottom: size.height * 0.15,
            child: AccelSlider(
              onChanged: (val) {
                setState(() => _currentValue = val);
              },
            ),
          ),

          // CONTROL DERECHO: DIRECCIÓN (Con efecto muelle)
          Positioned(
            right: 50,
            bottom: size.height * 0.2,
            child: SteeringSlider(
              onChanged: (val) {
                setState(() => _steeringValue = val);
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: NeonConnectButton(
              status: _connectionStatus,
              onTap: _handleConnect,
            ),
          ),
        ],
      ),
    );
  }
}