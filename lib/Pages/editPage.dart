import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String selectedGender = 'Femme';
  final TextEditingController firstNameController =
      TextEditingController(text: 'Emma');
  final TextEditingController lastNameController =
      TextEditingController(text: 'Harris');
  final TextEditingController birthDateController =
      TextEditingController(text: '16 / 04 / 1992');
  final TextEditingController goalController =
      TextEditingController(text: 'Maintenir une humeur stable.');
  final TextEditingController aboutController = TextEditingController();

  static const Color primary = Color(0xFF9C89FF);
  static const Color primaryLight = Color(0xFFEDE7FF);
  static const Color background = Color(0xFFF5F0FF);
  static const Color cardBg = Colors.white;
  static const Color labelColor = Color(0xFFB0A3E0);
  static const Color textColor = Color(0xFF2A1F5C);
  static const Color sectionLabelColor = Color(0xFF9C89FF);
  static const Color borderColor = Color(0xFFD8CCF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Modifier mon profil',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Center(
              child: Text(
                'Mets à jour tes informations personnelles.',
                style: TextStyle(
                  fontSize: 14,
                  color: primary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),

            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: primaryLight,
                    child: const Icon(Icons.person, size: 40, color: primary),
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('Changer la photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF5C4EA0),
                      backgroundColor: primaryLight,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Section: Identité
            _buildSectionLabel('Identité'),
            const SizedBox(height: 10),
            _buildField(
              label: 'Prénom',
              controller: firstNameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 10),
            _buildField(
              label: 'Nom',
              controller: lastNameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),

            // Section: Genre
            _buildSectionLabel('Genre'),
            const SizedBox(height: 10),
            _buildGenderSelector(),
            const SizedBox(height: 24),

            // Section: Naissance & objectif
            _buildSectionLabel('Naissance & objectif'),
            const SizedBox(height: 10),
            _buildField(
              label: 'Date de naissance',
              controller: birthDateController,
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 10),
            _buildField(
              label: 'Objectif personnel',
              controller: goalController,
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 24),

            // Section: À propos
            _buildSectionLabel('À propos'),
            const SizedBox(height: 10),
            _buildField(
              label: 'À propos de moi',
              controller: aboutController,
              icon: Icons.edit_note_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Buttons
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              child: const Text('Enregistrer les modifications'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: sectionLabelColor,
        letterSpacing: 0.9,
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['Homme', 'Femme', 'Autre'].map((gender) {
        final isSelected = selectedGender == gender;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: gender != 'Autre' ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => selectedGender = gender),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primary : cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primary : borderColor,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      gender,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF7A6ABF),
                      ),
                    ),
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