import 'package:emotion_app/Pages/Connexion.dart';
import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/Pages/createProfil.dart';
import 'package:emotion_app/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // final String nom;
    // final String prenom;
    // final String genre;

    final service = ProfileService();
    Future<bool>? _profilFuture;
    String? _lastUserId;

    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, authSnapshot) {

        if(!authSnapshot.hasData){
          return const Scaffold(
            body : Center(child : CircularProgressIndicator()),
          );
        }

        final session = authSnapshot.data!.session;

        if (session == null) {
          return const Connexion();
        } 

        final userId = session.user.id;

        if (_lastUserId != userId || _profilFuture == null) {
          _lastUserId = userId;
          _profilFuture = service.profilExiste(userId);
        } 

       return FutureBuilder<bool>(
          future: _profilFuture, 
          builder: (context, prfilsnapshot){

            if (prfilsnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (prfilsnapshot.hasError){
              return Scaffold(
                body: Center(
                  child: Text("Erreur lors de la vérification du profil: ${prfilsnapshot.error}"),
                  ),
              );
            }

            final existe = prfilsnapshot.data?? false;

              if (existe) {
                return  Acceuil(
                  userId : userId,
                );
              }
              else{
                return const Createprofil();
              }
          }
       );
      }
    );
  }



  
}