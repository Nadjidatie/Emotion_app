import 'package:emotion_app/Pages/acceuil.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({
    super.key,
    });


  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => 
            //   Acceuil(
            //     userId: userId,
            //   )),
            // ); // Retour à l'accueil
          },
        ),
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: const Center(
        child: Text(
          "Page Profil (vide)",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
