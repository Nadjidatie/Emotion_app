import 'package:emotion_app/Pages/CalendrierPage.dart';
import 'package:emotion_app/Pages/ajouterHumeurQuestionnaire.dart';
import 'package:emotion_app/Pages/profilPage.dart';
import 'package:emotion_app/widgets/navigationBarBoutton.dart';
import 'package:emotion_app/widgets/phaseActuelle.dart';
import 'package:emotion_app/widgets/profilPhotoDefaut.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Acceuil extends StatefulWidget {
  final String userId;

  const Acceuil({super.key, required this.userId});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final profileStream = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', widget.userId);

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: profileStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFFB79CED)),
                ),
              );
            }

            final profile = snapshot.hasData && snapshot.data!.isNotEmpty
                ? snapshot.data!.first
                : null;

            String salutation = 'Bonjour 🌸';
            String? imageUrl;
            Sexe sexe = Sexe.autre;

            if (profile != null) {
              final prenom = profile['prenom'] as String?;
              if (prenom != null && prenom.isNotEmpty) {
                salutation = 'Bonjour $prenom 🌸';
              }

              imageUrl = profile['image_url'] as String?;
              final genre = (profile['genre'] ?? '').toString().toLowerCase();
              if (genre == 'homme') {
                sexe = Sexe.homme;
              } else if (genre == 'femme') {
                sexe = Sexe.femme;
              }
            }

            return RefreshIndicator(
              color: const Color(0xFFB79CED),
              onRefresh: () async => setState(() {}),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  salutation,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4C4A73),
                                  ),
                                ),
                                const Text(
                                  'Comment te sens-tu aujourd\'hui ?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8B87A3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfilPage(userId: widget.userId),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFEDE7FF),
                              backgroundImage: imageUrl != null
                                  ? NetworkImage(imageUrl)
                                  : null,
                              child: imageUrl == null
                                  ? ClipOval(
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child:
                                            ProfilPhotoDefaut(genre: sexe),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    PhaseActuelle(
                      onTapQuestionnaire: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AjouterHumeurQuestionnaire(),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CalendrierPage(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE8DDF5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB79CED)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: Color(0xFFB79CED),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mon calendrier',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4C4A73),
                                      ),
                                    ),
                                    Text(
                                      'Visualise ton cycle et tes humeurs',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8B87A3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF8B87A3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          child: Navigationbarboutton(
            userId: widget.userId,
            currentRoute: 'acceuil',
          ),
        ),
      ),
    );
  }
}
