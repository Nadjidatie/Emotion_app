// import 'package:emotion_app/Pages/Connexion.dart';
// import 'package:emotion_app/Pages/Inscription.dart';
// import 'package:emotion_app/Pages/createProfil.dart';
import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/Pages/chat_page.dart';
import 'package:emotion_app/Pages/createProfil.dart';
import 'package:emotion_app/auth/auth_gate.dart';
// import 'package:emotion_app/Pages/Inscription.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  await Supabase.initialize(
    url: "https://mftyadvkuddrtfrodgmd.supabase.co",
    anonKey: "sb_publishable_5DHv6pItqNPUqQr2kQjRaA_UEEVzx_L",
  );
      
    runApp(const MyApp());
}


// Classe principale
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AuthGate(),
    );
  }
}
