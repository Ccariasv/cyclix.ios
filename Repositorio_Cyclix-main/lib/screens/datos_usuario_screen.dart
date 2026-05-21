import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/auth_service.dart';
import '../theme/cyclix_colors.dart';
import '../widgets/cyclix_header.dart';

class DatosUsuarioScreen extends StatefulWidget {
  const DatosUsuarioScreen({super.key});

  @override
  State<DatosUsuarioScreen> createState() => _DatosUsuarioScreenState();
}

class _DatosUsuarioScreenState extends State<DatosUsuarioScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic>? userData;
  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _authService.getUserData();
    final photoPath = await _authService.getProfilePhotoPath();
    if (!mounted) return;
    setState(() {
      userData = data;
      _profilePhotoPath = photoPath;
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      maxWidth: 900,
      imageQuality: 82,
    );
    if (image == null) return;
    final directory = await getApplicationDocumentsDirectory();
    final extension = image.path.split('.').last;
    final savedFile = await File(image.path).copy(
      '${directory.path}/cyclix_profile_${DateTime.now().millisecondsSinceEpoch}.$extension',
    );
    await _deleteCurrentPhotoFile();
    await _authService.saveProfilePhotoPath(savedFile.path);
    if (!mounted) return;
    setState(() => _profilePhotoPath = savedFile.path);
  }

  Future<void> _removePhoto() async {
    await _deleteCurrentPhotoFile();
    await _authService.removeProfilePhotoPath();
    if (!mounted) return;
    setState(() => _profilePhotoPath = null);
  }

  Future<void> _deleteCurrentPhotoFile() async {
    final current = _profilePhotoPath;
    if (current == null) return;
    final file = File(current);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              20 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Elegir desde galería'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Tomar foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                if (_profilePhotoPath != null)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    title: const Text('Quitar foto'),
                    onTap: () {
                      Navigator.pop(context);
                      _removePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyclixColors.backgroundWhite,
      appBar: const CyclixHeader(showBack: true),
      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(color: CyclixColors.primaryBlue),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                32 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: CyclixColors.primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundColor: CyclixColors.cardGrey,
                                  backgroundImage:
                                      _profilePhotoPath != null &&
                                          File(_profilePhotoPath!).existsSync()
                                      ? FileImage(File(_profilePhotoPath!))
                                      : null,
                                  child:
                                      _profilePhotoPath == null ||
                                          !File(_profilePhotoPath!).existsSync()
                                      ? const Icon(
                                          Icons.person,
                                          size: 70,
                                          color: CyclixColors.primaryBlue,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: CyclixColors.accentGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _showPhotoOptions,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(
                            _profilePhotoPath == null
                                ? 'Agregar foto'
                                : 'Cambiar o quitar foto',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${userData!['firstName'] ?? 'Usuario'} ${userData!['lastName'] ?? ''}",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CyclixColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Información Personal",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CyclixColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard([
                    _buildInfoTile(
                      Icons.person_outline,
                      "Nombre Completo",
                      "${userData!['firstName'] ?? ''} ${userData!['lastName'] ?? ''}",
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      Icons.email_outlined,
                      "Correo Electrónico",
                      userData!['email'] ?? 'No disponible',
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      Icons.phone_android_outlined,
                      "Teléfono",
                      userData!['phone'] ?? 'No disponible',
                    ),
                  ]),
                  const SizedBox(height: 30),
                  Text(
                    "Estado de Cuenta",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CyclixColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard([
                    _buildInfoTile(
                      Icons.verified_user_outlined,
                      "Estado del Usuario",
                      "ACTIVO",
                    ),
                  ]),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _authService.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        "CERRAR SESIÓN",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyclixColors.cardGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.withValues(alpha: 0.2), height: 20);
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: CyclixColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: CyclixColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
