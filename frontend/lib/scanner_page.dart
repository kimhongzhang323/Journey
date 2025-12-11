import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto: // Handle auto if needed, or default
                    return const Icon(Icons.flash_auto, color: Colors.yellow);
                   case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.grey); 
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.cameraDirection) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                   setState(() {
                      _isScanned = true;
                   });
                   debugPrint('Barcode found! ${barcode.rawValue}');
                   // HapticFeedback.mediumImpact(); // Optional
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Scanned: ${barcode.rawValue}')),
                   );
                   // Navigate back or to result page
                   Future.delayed(const Duration(seconds: 1), () {
                     if (mounted) Navigator.pop(context, barcode.rawValue);
                   });
                   break; // Stop after first code
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                   // Corners
                   Positioned(top: 0, left: 0, child: _buildCorner(0)),
                   Positioned(top: 0, right: 0, child: _buildCorner(1)),
                   Positioned(bottom: 0, left: 0, child: _buildCorner(2)),
                   Positioned(bottom: 0, right: 0, child: _buildCorner(3)),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(int position) {
    // 0: TL, 1: TR, 2: BL, 3: BR
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: (position == 0 || position == 1) ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
          bottom: (position == 2 || position == 3) ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
          left: (position == 0 || position == 2) ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
          right: (position == 1 || position == 3) ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}
