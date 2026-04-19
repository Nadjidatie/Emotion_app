import 'package:emotion_app/auth/auth_service.dart';
import 'package:emotion_app/widgets/logoutBoutton.dart';
import 'package:emotion_app/widgets/navigationBarBoutton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Acceuil extends StatefulWidget {

  final String userId;
  const Acceuil({
    super.key,
    required this.userId
  });

    @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {

  @override
  Widget build(BuildContext context) {
    
      final AuthService _authService = AuthService();

      void logout() async {
        await _authService.signOut();
      }

     String titre;
     final supabase = Supabase.instance.client;

    return FutureBuilder(
      future : supabase
        .from('profiles')
        .select('nom, prenom, genre')
        .eq('id', widget.userId)
        .maybeSingle(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

        }


        final data = snapshot.data ;

        if (data == null ){
          print('data : $data');
          return const Scaffold(
            body: Center(child: Text("Profil non trouvé"))
          );
        }
        final nom = data['nom'] as String?;
        final prenom = data['prenom'] as String?;  
        final genre = data['genre'] as String?;


        if (genre == "Homme") {
        titre = "Bienvenue Mr $nom $prenom";
        } else if (genre == "Femme") {
          titre = "Bienvenue Mme $nom $prenom";
        } else {
          titre = "Bienvenue $nom $prenom";
        }
        return Scaffold (
          body: Stack(
            children: [
              Center(
                child: Text(
                  titre,
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold
                  ),
                ),


              ),

              Positioned(
                top: 15,
                right: 16,
                child: LogoutButton(onPressed: logout),
              ),
               
          ],
            
        ),
        //doit etre dans scaffold et non pas stack
          bottomNavigationBar: Container(
            color: Colors.white, 
            child: SafeArea(
              child: Navigationbarboutton(userId: widget.userId,), 
            ),
          ),
        );
      }
    );      
  }
  

}
