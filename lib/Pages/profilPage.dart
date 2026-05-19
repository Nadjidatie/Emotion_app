import 'package:emotion_app/Pages/editPage.dart';
import 'package:flutter/material.dart';
import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/widgets/profilPhotoDefaut.dart';

class ProfilPage extends StatefulWidget {
  final String nom;
  final String imageUrl;
  final int joursMembre;
  final String userId;
  final Sexe genre;

  const ProfilPage({
    super.key,
    required this.nom,
    required this.imageUrl,
    required this.joursMembre,
    required this.userId,
    required this.genre,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color.fromARGB(255, 247, 242, 255) ,
      appBar: AppBar(
        backgroundColor:  Color.fromARGB(255, 250, 246, 255) ,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Acceuil(userId: widget.userId)),
            );
          },
        ),
        title: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 60,
                height: 60,
                child: widget.imageUrl.isNotEmpty
                    ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                    : ProfilPhotoDefaut(genre: widget.genre),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mon Profil",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
            //const SizedBox(height: 20),
            //const Divider(color: Color(0xFFE8DDF5), thickness: 1),
            const SizedBox(height: 6),

              // 🔹 Ligne décorative
              Container(
                width: 250,
                height: 2,
                color: Colors.grey.shade300,
              ),

              const SizedBox(height: 10),
                Text(
                  widget.nom,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
         // mainAxisAlignment: MainAxisAlignment.center,      centre verticalement
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Membre depuis ${widget.joursMembre} jours",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfilePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B8AFB), 
                foregroundColor: Colors.white,             // texte blanc
                minimumSize: const Size(420, 45),          // largeur et hauteur
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25), // coins arrondis
                ),
                elevation: 0,                              // sans ombre
              ),
              child: const Text(
                "Modifier mon profil",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}