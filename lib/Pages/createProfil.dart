import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/auth/auth_service.dart';
import 'package:emotion_app/services/profile_service.dart';
import 'package:emotion_app/widgets/dateNaissance.dart';
import 'package:emotion_app/widgets/input.dart';
import 'package:emotion_app/widgets/logoutBoutton.dart';
import 'package:flutter/material.dart';
import 'package:emotion_app/widgets/selectGenre.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Createprofil extends StatefulWidget {

  const Createprofil({super.key});

  @override
  State<Createprofil> createState() => _CreateprofilState();
}

class _CreateprofilState extends State<Createprofil> {

  final AuthService _authService = AuthService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _objectifController= TextEditingController();
  
  void logout() async {
    await _authService.signOut();
  }

  DateTime? dateNaissance;
  String? selectedGenre;
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final userId = session!.user.id;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 245, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: LogoutButton(onPressed: logout),
                    ),
          
      

                    SizedBox(height: 5,),
                    
                    Center(
                      child: Text("Créer votre profil🌸 ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C4A73),
                    )
                    
                      


                    ),),

                    SizedBox(height: 8,),
                    
                    Center(
                      child: Text("Personnalise ton espace de bien-être ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7E7A9A),
                      ),),
                    ),

                    

                    SizedBox(height: 28,),

                    Input(
                      title : "Nom",
                      label: "Ton nom ",
                      controller: _nomController,),

                      SizedBox(height: 18,),

                    Input(
                      title: "Prénom",
                      label: "Ton prénom",
                      controller: _prenomController,),

                    SizedBox(height: 18,),

                    Datenaissance(
                      value: dateNaissance,
                      onChanged: (newDte){
                        setState(() => dateNaissance = newDte);
                      }

                      ),

                    SizedBox(height: 18,),

                    
                    SelectGenre(
                      selected : selectedGenre,
                      onChanged : (value) => setState(() => selectedGenre = value),
                    ),

                    SizedBox(height: 18,),

                    Input(
                      title : "Objetif personnel",
                      label: "Ton objectif personnel...",
                      controller: _objectifController
                    ),

                    SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {

                          if (
                            _nomController.text.isEmpty ||
                            _prenomController.text.isEmpty ||
                            dateNaissance == null ||
                            selectedGenre == null
                          ) {
                            // erreur 
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Veuillez remplir tous les champs"))
                            );
                            return;
                          }
                          final service = ProfileService();
                          
                          await service.saveProfil(
                            nom: _nomController.text, 
                            prenom: _prenomController.text,
                            datenaissance: dateNaissance!, 
                            genre: selectedGenre!,
                            objective: _objectifController.text.isEmpty ? null: _objectifController.text,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => 
                            Acceuil(
                              userId: userId,
                            )),
                          );
                        },
                        child: Text("Continuer", style: TextStyle(
                          fontSize: 20)),
                      ),
                    ),

                    SizedBox(height: 18,),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE8DDF5),)),             
                        SizedBox(width: 10,),
                        Text(
                          "Tu pourras modifier ces informations plus tard",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B87A3),

                          ),
                        ),

                        SizedBox(width: 10,),
                        Expanded(child: Divider(color: Color(0xFFE8DDF5),)), 

                      ],
                    )
                  
                  ],
        
                ),
             ),
            ),
          ),
        ),
      ),
    );
  }
}