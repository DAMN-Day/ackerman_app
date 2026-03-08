import 'package:flutter/material.dart';
import '../../core/constants.dart';

enum ConnectionStatus { disconnected, connecting, connected }

class NeonConnectButton extends StatefulWidget {
  final ConnectionStatus status;
  final VoidCallback onTap;

  const NeonConnectButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<NeonConnectButton> createState() => _NeonConnectButtonState();
}

class _NeonConnectButtonState extends State<NeonConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(NeonConnectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia a 'connecting', empezamos el parpadeo
    if (widget.status == ConnectionStatus.connecting) {
      _blinkController.repeat(reverse: true);
    } else {
      _blinkController.stop();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _blinkController,
        builder: (context, child) {
          // Lógica de colores basada en el estado
          Color currentColor;
          double glowOpacity;
          String label;

          if (widget.status == ConnectionStatus.connecting) {
            // Parpadeo: interpola entre el azul tenue y el azul neón fuerte
            currentColor = Color.lerp(
              DashboardColors.ghostBlue,
              DashboardColors.neonBlue,
              _blinkController.value,
            )!;
            glowOpacity = _blinkController.value * 0.5;
            label = "SEARCHING...";
          } else if (widget.status == ConnectionStatus.connected) {
            currentColor = DashboardColors.neonBlue;
            glowOpacity = 0.6;
            label = "SYSTEM ONLINE";
          } else {
            currentColor = DashboardColors.ghostBlue.withOpacity(0.5);
            glowOpacity = 0.0;
            label = "CONNECT SYSTEM";
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: DashboardColors.darkBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: currentColor, width: 1.5),
              boxShadow: [
                if (glowOpacity > 0)
                  BoxShadow(
                    color: currentColor.withOpacity(glowOpacity),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.status == ConnectionStatus.connected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth,
                  color: currentColor,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: currentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}