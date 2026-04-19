import 'package:emotion_app/Pages/Inscription.dart';
import 'package:emotion_app/auth/auth_service.dart';
import 'package:emotion_app/widgets/input.dart';
import 'package:emotion_app/widgets/square.dart';
import 'package:flutter/material.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {

// get auth service
  final AuthService _authService = AuthService(); 

//text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    //se connecter
    try{
      await _authService.signInWithEmailPassword(email, password);
    } 
    //erreur de connextion
    catch (e){
      if (mounted){
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur de connexion : $e")));
      }
    }
  }

  void signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur de connexion Google : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( 
          child: Container(
          padding: EdgeInsets.only(top: 30),
          margin : EdgeInsets.all(30),
            child: Column(
              children: [

                Text("Ravi de te revoir🌸", style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C4A73),

                ),),

                SizedBox(height: 5,),
                Text("Connecte-toi pour suivre ton humeur."),

                SizedBox(height: 40,),

              Form(
                child: Column(
                  children: [
                    Input(
                      title: 'Email',
                      label: 'email',
                      controller: _emailController,
                      ),

                      SizedBox(height: 18 ,),

                    Input(
                      title: 'Mot de passe',
                      label: 'mot de passe',
                      controller: _passwordController,
                       obscureText: true
                    ),

                    SizedBox(height: 28,),
                    // le sizedbox pour que ça prenne toute la largeur du tel
                    //  SizedBox(
                    //   width: double.infinity,
                    //  child:
                    //    ElevatedButton(
                    //   onPressed: (){},
                    //     child: Text("Se connecter")),
                    // ),
        
                    ElevatedButton(
                      onPressed: login,
                        child: Text("Se connecter", style: TextStyle(
                          fontSize: 20)),
                        ),
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
                        Square(
                          path : "assets/images/googleLogo.png",
                          wight: 30,
                          onTap: signInWithGoogle,
                          ),
                        SizedBox(width: 20,),
                        Square(path : "assets/images/appleLogo.webp", wight: 50,),
                    ],
                    ),
                      SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Pas de compte ? "),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Inscription())
                            );
                      },
                          child: Text ("Inscrivez-vous", style: TextStyle(
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
      ));
  }
}