import 'package:emotion_app/Pages/Connexion.dart';
import 'package:emotion_app/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:emotion_app/widgets/input.dart';
import 'package:emotion_app/widgets/square.dart';


class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {

  final AuthService _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();    
  final _confirmPasswordController = TextEditingController();

  void signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    try{
      await _authService.signUpWithEmailPassword(email, password);
      Navigator.pop(context);

    }
    catch (e){
      if (mounted){
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur d'inscription : $e")));
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          child: Container(
          padding: EdgeInsets.only(top: 5),
          margin : EdgeInsets.all(30),
            child: Column(
              children: [

                Text("Bienvenue ", style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C4A73),

                ),),

                SizedBox(height: 5,),
                Text("Crée ton espace bien-être personnel."
                ),

                SizedBox(height: 40,),

              Form(
                child: Column(
                  children: [
                  //   Input( label: 'Nom',),

                  //  Input( label: 'Prénom',),

                   Input(
                    title: 'Email',
                    label: 'email',
                    controller:_emailController,
                    ),

                    SizedBox(height: 18,),
                    Input(
                      title: 'Mot de passe',
                      label: 'mot de passe',
                      controller: _passwordController,
                      obscureText: true
                    ),
                    
                     SizedBox(height: 18,),

                    Input(
                      title: 'Confirmer mot de passe',
                      label: 'confirmer mot de passe',
                      controller: _confirmPasswordController,
                      obscureText: true
                    ),  
                  
                   

                SizedBox(height: 20,),
                // le sizedbox pour que ça prenne toute la largeur du tel
                //  SizedBox(
                //   width: double.infinity,
                //  child:
                   ElevatedButton(
                  onPressed: signUp,
                    child: Text("S'inscrire", style: TextStyle(
                      fontSize: 20)),
                    ),
                   // pour que le bouton prenne toute la largeur du téléphone
                    
                //),
    
                 SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(thickness : 0.5)), // qui permet de metttre un tiret
                    Padding( padding : EdgeInsets.symmetric(horizontal: 10), child : Text("ou continuer avec")),
                    Expanded(child: Divider(thickness : 0.5)),
                  ],
                ),

                  SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Square(path : "assets/images/googleLogo.png", wight: 30,),
                    SizedBox(width: 20,),
                    Square(path : "assets/images/appleLogo.webp", wight: 50,),
                ],
                ),
                  SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text("Déja inscrit ? "),
                     GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Connexion()),
                        );
                      },
                      child: Text ("Connectez-vous", style: TextStyle(
                        color:Colors.red,
                        fontWeight: FontWeight.bold  //Pour que ça soit en gras
                      ))
                     )
                  ],
                )
                  ]
                ),
        
              ),
            ],
            ),

          ),
        ),
      )
    );
  }
}