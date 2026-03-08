import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ackerman_app/core/constants.dart';
import 'package:ackerman_app/ui/widgets/tachometer_painter.dart';
import 'package:ackerman_app/ui/widgets/segmented_gauge.dart';
import 'package:ackerman_app/ui/widgets/accel_slider.dart';
import 'package:ackerman_app/ui/widgets/steering_slider.dart';
import 'package:ackerman_app/ui/widgets/connect_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  BluetoothConnection? connection;
  bool isConnecting = false;

  void _handleConnect() async {
    await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();
    if (_connectionStatus == ConnectionStatus.disconnected) {
      setState(() => _connectionStatus = ConnectionStatus.connecting);

      try {
        // 1. Obtener dispositivos emparejados
        List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
        
        // 2. Buscar tu ESP32 (Asegúrate de que el nombre coincida con tu código de Arduino)
        BluetoothDevice? server = bondedDevices.firstWhere(
          (device) => device.name == "ESP32_Robot", // <--- CAMBIA ESTO al nombre de tu ESP32
        );

        // 3. Intentar conectar
        BluetoothConnection.toAddress(server.address).then((_connection) {
          print('Conectado al robot!');
          connection = _connection;
          setState(() => _connectionStatus = ConnectionStatus.connected);

          // Escuchar datos que envíe el ESP32 (opcional)
          connection!.input!.listen((Uint8List data) {
            print('Data recibida: ${ascii.decode(data)}');
          });

        }).catchError((error) {
          print('Error de conexión: $error');
          setState(() => _connectionStatus = ConnectionStatus.disconnected);
        });

      } catch (e) {
        print("No se encontró el dispositivo emparejado");
        setState(() => _connectionStatus = ConnectionStatus.disconnected);
      }
    } else {
      // Desconectar
      await connection?.close();
      setState(() => _connectionStatus = ConnectionStatus.disconnected);
    }
  }

  void _sendData(double velocity, double direction) {
    if (connection != null && connection!.isConnected) {
      // Mapeamos los valores a rangos que el ESP32 entienda (0-255 para velocidad, 0-100 para dirección)
      int v = (velocity * 255).toInt();
      int d = (direction * 100).toInt();

      // Formato de cadena: "V:100,D:50\n"
      String data = "<$v,$d>\n";
      connection!.output.add(Uint8List.fromList(utf8.encode(data)));
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
                _sendData(_currentValue, _steeringValue); // Enviar datos actualizados
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
                _sendData(_currentValue, _steeringValue); // Enviar datos actualizados
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