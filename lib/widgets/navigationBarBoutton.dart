import 'package:emotion_app/Pages/acceuil.dart';
import 'package:emotion_app/Pages/calendarPage.dart';
import 'package:emotion_app/Pages/chat_page.dart';
import 'package:emotion_app/Pages/profilPage.dart';
import 'package:emotion_app/Pages/questionnairePage.dart';
import 'package:emotion_app/Pages/statPage.dart';
import 'package:emotion_app/widgets/menuItem.dart';
import 'package:flutter/material.dart';

/// Barre de navigation inférieure réutilisée sur tous les écrans principaux.
///
/// Le paramètre [currentRoute] permet de mettre en surbrillance l'icône de
/// l'écran actif sans dupliquer ce composant pour chaque page.
class Navigationbarboutton extends StatelessWidget {
  final String userId;
  final String currentRoute;

  const Navigationbarboutton({
    super.key,
    required this.userId,
    this.currentRoute = 'accueil',
  });

  void _go(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MenuItem(
                icon: Icons.home,
                texte: 'Accueil',
                isSelected: currentRoute == 'accueil',
                onTap: () => _go(context, Acceuil(userId: userId)),
              ),
              MenuItem(
                icon: Icons.calendar_month,
                texte: 'Calendrier',
                isSelected: currentRoute == 'calendrier',
                onTap: () => _go(context, const CalendarPage()),
              ),
              MenuItem(
                icon: Icons.add_circle,
                texte: 'Humeur',
                isSelected: currentRoute == 'questionnaire',
                onTap: () => _go(context, const QuestionnairePage()),
              ),
              MenuItem(
                icon: Icons.bar_chart,
                texte: 'Stats',
                isSelected: currentRoute == 'stats',
                onTap: () => _go(context, const StatPage()),
              ),
              MenuItem(
                icon: Icons.chat_bubble_outline_outlined,
                texte: 'Chatbot',
                isSelected: currentRoute == 'chatbot',
                onTap: () => _go(context, const ChatPage()),
              ),
              MenuItem(
                icon: Icons.person,
                texte: 'Profil',
                isSelected: currentRoute == 'profil',
                onTap: () => _go(context, const ProfilPage()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
