import 'package:flutter/material.dart';

import 'Connexion.dart';
import 'Inscription.dart';
import 'acceuil.dart';
import 'calendarPage.dart';
import 'chat_page.dart';
import 'createProfil.dart';
import 'profilPage.dart';
import 'questionnairePage.dart';
import 'statPage.dart';

/// Menu de développement — permet de naviguer vers tous les écrans de
/// l'app sans passer par l'authentification Supabase.
///
/// Utile pour tester le rendu de chaque page tant que le projet Supabase
/// est en pause ou hors-ligne.
///
/// **Pour désactiver ce menu et revenir à l'écran de connexion normal :**
///   1. Ouvrir `lib/main.dart`
///   2. Remplacer `home: const DevMenuPage()` par `home: const AuthGate()`
class DevMenuPage extends StatelessWidget {
  const DevMenuPage({super.key});

  /// userId factice pour les écrans qui en ont besoin (Acceuil).
  /// Aucune requête Supabase ne réussira avec, mais Acceuil est conçu
  /// pour afficher quand même une UI par défaut ("Bonjour 🌸").
  static const _fakeUserId = '00000000-0000-0000-0000-000000000000';

  @override
  Widget build(BuildContext context) {
    final ecrans = <_EcranEntree>[
      _EcranEntree(
        nom: 'Accueil',
        description: 'Carte de phase + raccourci calendrier',
        icone: Icons.home,
        couleur: const Color(0xFFB79CED),
        builder: () => const Acceuil(userId: _fakeUserId),
      ),
      _EcranEntree(
        nom: 'Calendrier',
        description: 'Calendrier coloré + fiche du jour',
        icone: Icons.calendar_month,
        couleur: const Color(0xFFB79CED),
        builder: () => const CalendarPage(),
      ),
      _EcranEntree(
        nom: 'Questionnaire',
        description: '10 questions, sliders + chips',
        icone: Icons.edit_note,
        couleur: const Color(0xFFE8A0A0),
        builder: () => const QuestionnairePage(),
      ),
      _EcranEntree(
        nom: 'Statistiques',
        description: 'Page vide (Étape 6)',
        icone: Icons.bar_chart,
        couleur: const Color(0xFFF5C97E),
        builder: () => const StatPage(),
      ),
      _EcranEntree(
        nom: 'Chatbot',
        description: 'Chat IA',
        icone: Icons.chat_bubble_outline,
        couleur: const Color(0xFFB7D4A8),
        builder: () => const ChatPage(),
      ),
      _EcranEntree(
        nom: 'Profil',
        description: 'Page profil (vide)',
        icone: Icons.person,
        couleur: const Color(0xFF7E7A9A),
        builder: () => const ProfilPage(),
      ),
      _EcranEntree(
        nom: 'Connexion',
        description: 'Écran de login',
        icone: Icons.login,
        couleur: const Color(0xFF4C4A73),
        builder: () => const Connexion(),
      ),
      _EcranEntree(
        nom: 'Inscription',
        description: 'Écran d\'inscription',
        icone: Icons.person_add,
        couleur: const Color(0xFF4C4A73),
        builder: () => const Inscription(),
      ),
      _EcranEntree(
        nom: 'Créer profil',
        description: 'Onboarding',
        icone: Icons.account_circle,
        couleur: const Color(0xFFD88FB5),
        builder: () => const Createprofil(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCF5FF),
        elevation: 0,
        title: const Text(
          'DEV — tous les écrans',
          style: TextStyle(
            color: Color(0xFF4C4A73),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF4C4A73)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Mode développement actif. Pour revenir à l\'écran '
                        'de connexion normal, modifie main.dart (instructions '
                        'dans devMenuPage.dart).',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4C4A73),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...ecrans.map((e) => _EcranTuile(entree: e)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EcranEntree {
  final String nom;
  final String description;
  final IconData icone;
  final Color couleur;
  final Widget Function() builder;

  const _EcranEntree({
    required this.nom,
    required this.description,
    required this.icone,
    required this.couleur,
    required this.builder,
  });
}

class _EcranTuile extends StatelessWidget {
  final _EcranEntree entree;
  const _EcranTuile({required this.entree});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDF5)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: entree.couleur.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(entree.icone, color: entree.couleur),
        ),
        title: Text(
          entree.nom,
          style: const TextStyle(
            color: Color(0xFF4C4A73),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          entree.description,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8B87A3),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF8B87A3)),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => entree.builder()),
        ),
      ),
    );
  }
}
