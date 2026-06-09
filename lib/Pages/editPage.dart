import 'dart:io';
import 'package:emotion_app/services/profile_service.dart';
import 'package:emotion_app/widgets/profilPhotoDefaut.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileService = ProfileService();
  final _picker = ImagePicker();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _goalController = TextEditingController();

  String _selectedGender = 'Autre';
  DateTime? _selectedDate;
  String? _imageUrl;
  File? _imageFile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  static const Color primary = Color(0xFF9C89FF);
  static const Color primaryLight = Color(0xFFEDE7FF);
  static const Color background = Color(0xFFF5F0FF);
  static const Color cardBg = Colors.white;
  static const Color labelColor = Color(0xFFB0A3E0);
  static const Color textColor = Color(0xFF2A1F5C);
  static const Color borderColor = Color(0xFFD8CCF5);

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadProfil() async {
    final userId = widget.userId;

    final data = await _profileService.getProfil(userId);
    if (data != null) {
      _firstNameController.text = data['prenom'] ?? '';
      _lastNameController.text = data['nom'] ?? '';
      _goalController.text = data['objective'] ?? '';
      _imageUrl = data['image_url'];
      _selectedGender = _normalizeGenre(data['genre'] ?? '');

      final rawDate = data['date_naissance'];
      if (rawDate != null) {
        _selectedDate = DateTime.tryParse(rawDate.toString());
        if (_selectedDate != null) _birthDateController.text = _formatDate(_selectedDate!);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: primary),
              title: const Text('Prendre une photo'),
              onTap: () { Navigator.pop(ctx); _selectImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () { Navigator.pop(ctx); _selectImage(ImageSource.gallery); },
            ),
            if (_imageUrl != null || _imageFile != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () { Navigator.pop(ctx); _removeImage(); },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _removeImage() => setState(() { _imageFile = null; _imageUrl = null; });

  Future<void> _save() async {
    setState(() { _isSaving = true; _errorMessage = null; });

    try {
      String? finalImageUrl = _imageUrl;
      if (_imageFile != null) {
        finalImageUrl = await _profileService.uploadPhoto(_imageFile!);
      } else if (_imageUrl == null) {
        await _profileService.supprimerPhoto();
      }

      await _profileService.saveProfil(
        nom: _lastNameController.text.trim(),
        prenom: _firstNameController.text.trim(),
        datenaissance: _selectedDate ?? DateTime(2000, 1, 1),
        genre: _selectedGender.toLowerCase(),
        objective: _goalController.text.trim(),
        imageUrl: finalImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil enregistré avec succès !'), backgroundColor: primary),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors de la sauvegarde. Réessaie.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: primary, onPrimary: Colors.white, surface: cardBg),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() { _selectedDate = picked; _birthDateController.text = _formatDate(picked); });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

  String _normalizeGenre(String raw) {
    final r = raw.toLowerCase();
    if (r == 'homme' || r == 'man' || r == 'm') return 'Homme';
    if (r == 'femme' || r == 'woman' || r == 'f') return 'Femme';
    return 'Autre';
  }

  Sexe get _sexeEnum {
    switch (_selectedGender) {
      case 'Homme': return Sexe.homme;
      case 'Femme': return Sexe.femme;
      default: return Sexe.autre;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Modifier mon profil', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Mets à jour tes informations personnelles.',
                        style: TextStyle(fontSize: 14, color: primary.withOpacity(0.7)),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 28),

                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: primaryLight,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : (_imageUrl != null ? NetworkImage(_imageUrl!) : null),
                            child: (_imageFile == null && _imageUrl == null)
                                ? ClipOval(child: SizedBox(width: 100, height: 100, child: ProfilPhotoDefaut(genre: _sexeEnum)))
                                : null,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 32, height: 32,
                              decoration: const BoxDecoration(color: primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text('Appuie pour changer la photo',
                        style: TextStyle(fontSize: 12, color: primary.withOpacity(0.6))),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionLabel('Identité'),
                  const SizedBox(height: 10),
                  _buildField('Prénom', _firstNameController, Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildField('Nom', _lastNameController, Icons.person_outline),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Genre'),
                  const SizedBox(height: 10),
                  _buildGenderSelector(),
                  const SizedBox(height: 24),

                  _buildSectionLabel('Naissance & objectif'),
                  const SizedBox(height: 10),
                  _buildDateField(),
                  const SizedBox(height: 10),
                  _buildField('Objectif personnel', _goalController, Icons.flag_outlined),
                  const SizedBox(height: 32),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFB3B3), width: 0.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Color(0xFFE24B4A), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: Color(0xFFA32D2D)))),
                      ]),
                    ),
                    const SizedBox(height: 16),
                  ],

                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      disabledBackgroundColor: primary.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Enregistrer les modifications'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 15),
                    ),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String label) => Text(label.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.9));

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: labelColor),
        prefixIcon: Icon(icon, color: labelColor, size: 20),
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderColor, width: 0.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: borderColor, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
      ),
    );
  }

  Widget _buildDateField() => GestureDetector(
    onTap: _pickDate,
    child: AbsorbPointer(child: _buildField('Date de naissance', _birthDateController, Icons.calendar_today_outlined)),
  );

  Widget _buildGenderSelector() {
    return Row(
      children: ['Homme', 'Femme', 'Autre'].map((gender) {
        final isSelected = _selectedGender == gender;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: gender != 'Autre' ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedGender = gender),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primary : cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? primary : borderColor, width: isSelected ? 1.5 : 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(gender, style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF7A6ABF),
                    )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}