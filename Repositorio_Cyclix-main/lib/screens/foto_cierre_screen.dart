import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/cyclix_colors.dart';
import '../widgets/cyclix_header.dart';

class FotoCierreScreen extends StatefulWidget {
  const FotoCierreScreen({super.key});

  @override
  State<FotoCierreScreen> createState() => _FotoCierreScreenState();
}

class _FotoCierreScreenState extends State<FotoCierreScreen> {
  CameraController? _controller;
  Future<void>? _cameraFuture;
  String? _errorMessage;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _cameraFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage =
              'No se encontró cámara disponible en este dispositivo.';
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo abrir la cámara. $e';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }

    setState(() => _capturing = true);
    try {
      final photo = await controller.takePicture();
      if (!mounted) return;
      Navigator.pop(context, photo.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo capturar la foto. $e')),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _simulatePhoto() {
    Navigator.pop(context, 'demo://foto-cierre');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CyclixHeader(showBack: true),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: _cameraFuture,
                builder: (context, snapshot) {
                  final controller = _controller;
                  if (_errorMessage != null) {
                    return _CameraFallback(message: _errorMessage!);
                  }
                  if (snapshot.connectionState != ConnectionState.done ||
                      controller == null ||
                      !controller.value.isInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: CyclixColors.accentGreen,
                      ),
                    );
                  }
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(controller),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Toma foto de la bicicleta bloqueada',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              color: CyclixColors.backgroundWhite,
              padding: EdgeInsets.fromLTRB(20, 16, 20, 18 + bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: _capturing ? null : _capturePhoto,
                    style: FilledButton.styleFrom(
                      backgroundColor: CyclixColors.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _capturing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt_outlined),
                    label: const Text('Capturar foto'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _simulatePhoto,
                    icon: const Icon(Icons.image_search_outlined),
                    label: const Text('Simular foto de cierre'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraFallback extends StatelessWidget {
  const _CameraFallback({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CyclixColors.textDark,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
