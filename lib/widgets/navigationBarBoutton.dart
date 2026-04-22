import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/Pages/chat_page.dart';
import 'package:emotion_app/Pages/profilPage.dart';
import 'package:emotion_app/Pages/statPage.dart';
import 'package:emotion_app/services/profile_service.dart';
import 'package:emotion_app/widgets/menuItem.dart';
import 'package:flutter/material.dart';

class Navigationbarboutton extends StatelessWidget {
  final String userId;
  const Navigationbarboutton({
    super.key,
    required this.userId
    });

  @override
  Widget build(BuildContext context) {
    
    return Column(
        mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),

        Container(
          height: 75,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            //color: Colors.white,
            //borderRadius: BorderRadius.circular(60),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.06),
            //     blurRadius: 8,
            //     offset: const Offset(0, 3),
            //   )
            // ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MenuItem(
                icon: Icons.home,
                texte: "Accueil",
                isSelected: true,
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => Acceuil(userId: userId),
                      )
                    );
                },
              ),

              MenuItem(
                icon: Icons.bar_chart,
                texte: "Statistique",
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => StatPage(),
                      )
                    );
                },
              ),

              MenuItem(
                icon: Icons.add_circle,
                texte: "Ajouter humeur",
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ProfilPage(),
                      )
                    );
                },
              ),

              MenuItem(
                icon: Icons.chat_bubble_outline_outlined,
                texte: "Chatbot",
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ChatPage(userId: userId,),
                      )
                    );
                },
              ),

              MenuItem(
                icon: Icons.person,
                texte: "Profil",
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ProfilPage(),
                      )
                    );
                },
              )

            ],
          ),
        )   
      ],
    );
     
  }
}
