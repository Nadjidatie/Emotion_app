import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/Pages/ajouterHumeurQuestionnaire.dart';
import 'package:emotion_app/Pages/calendrierPage.dart';
import 'package:emotion_app/Pages/chat_page.dart';
import 'package:emotion_app/Pages/statPage.dart';
import 'package:emotion_app/widgets/menuItem.dart';
import 'package:flutter/material.dart';

class Navigationbarboutton extends StatelessWidget {
  final String userId;
  final String currentRoute;

  const Navigationbarboutton({
    super.key,
    required this.userId,
    this.currentRoute = 'acceuil',
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
                isSelected: currentRoute == 'acceuil',
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
                icon: Icons.calendar_month,
                texte: 'Calendrier',
                isSelected: currentRoute == 'calendrier',
                onTap: () => {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => CalendrierPage(),
                      )
                    )
                },
              ),

              MenuItem(
                icon: Icons.bar_chart,
                texte: "Stat",
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => StatPage(userId: userId,),
                      )
                    );
                },
              ),

              MenuItem(
                icon: Icons.add_circle,
                texte: "Humeur",
                 isSelected: currentRoute == 'questionnaire',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AjouterHumeurQuestionnaire()),
                  ),
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
              )

            ],
          ),
        )   
      ],
    );
     
  }
}
