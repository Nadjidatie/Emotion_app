import 'package:emotion_app/Pages/editPage.dart';
import 'package:emotion_app/auth/auth_service.dart';
import 'package:emotion_app/services/profile_service.dart';
import 'package:emotion_app/widgets/profilPhotoDefaut.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatefulWidget {
  final String userId;
  const ProfilPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _profileService = ProfileService();
  final _authService = AuthService();

  String _prenom = '';
  String _nom = '';
  String? _imageUrl;
  Sexe _sexe = Sexe.autre;
  int _joursMembre = 0;
  bool _isLoading = true;

  static const Color primary = Color(0xFF9C89FF);
  static const Color primaryLight = Color(0xFFEDE7FF);
  static const Color background = Color(0xFFF5F0FF);

  @override
  void initState() {
    super.initState();
    _loadProfil();
  }

  Future<void> _loadProfil() async {
    final userId = widget.userId;

    final data = await _profileService.getProfil(userId);
    if (data != null) {
      setState(() {
        _prenom = data['prenom'] ?? '';
        _nom = data['nom'] ?? '';
        _imageUrl = data['image_url'];
        _joursMembre = data['jours_membre'] ?? 0;

        final genre = (data['genre'] ?? '').toString().toLowerCase();
        if (genre == 'homme') {
          _sexe = Sexe.homme;
        } else if (genre == 'femme') {
          _sexe = Sexe.femme;
        } else {
          _sexe = Sexe.autre;
        }
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: primaryLight,
                    backgroundImage:
                        _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                    child: _imageUrl == null
                        ? ClipOval(
                            child: SizedBox(
                              width: 104,
                              height: 104,
                              child: ProfilPhotoDefaut(genre: _sexe),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_prenom $_nom'.trim(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A1F5C),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Membre depuis $_joursMembre jour${_joursMembre > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9C89FF),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(userId: widget.userId),
                        ),
                      );
                      _loadProfil();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Modifier mon profil'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE45C5C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
    );
  }
}