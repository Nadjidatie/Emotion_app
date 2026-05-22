import 'package:emotion_app/Pages/calendrierPage.dart';
import 'package:emotion_app/Pages/ajouterHumeurQuestionnaire.dart';
import 'package:emotion_app/auth/auth_service.dart';
import 'package:emotion_app/widgets/phaseActuelle.dart';
import 'package:emotion_app/widgets/logoutBoutton.dart';
import 'package:emotion_app/widgets/navigationBarBoutton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Acceuil extends StatefulWidget {
  final String userId;
  const Acceuil({super.key, required this.userId});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  final AuthService _authService = AuthService();

  void logout() async {
    await _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF5FF),
      body: SafeArea(
        child: FutureBuilder(
          // timeout 3s pour ne pas bloquer l'UI si Supabase est en pause
          future: supabase
              .from('profiles')
              .select('nom, prenom, genre')
              .eq('id', widget.userId)
              .maybeSingle()
              .timeout(const Duration(seconds: 3), onTimeout: () => null),
          builder: (context, snapshot) {
            // Affiche un spinner court, mais si l'attente dure → on continue
            // avec un fallback "Bonjour 🌸" pour ne pas bloquer l'app.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFFB79CED)),
                ),
              );
            }

            // Si Supabase indisponible (snapshot.hasError) ou pas de data,
            // on affiche quand même l'UI — pas de blocage.
            String salutation = 'Bonjour 🌸';
            final data = snapshot.hasError ? null : snapshot.data;
            if (data != null) {
              final prenom = data['prenom'] as String?;
              if (prenom != null && prenom.isNotEmpty) {
                salutation = 'Bonjour $prenom 🌸';
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
                    // === Header ===
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
                          LogoutButton(onPressed: logout),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // === Carte phase courante ===
                    PhaseActuelle(
                      onTapQuestionnaire: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ajouterHumeurQuestionnaire(),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // === Raccourci calendrier ===
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CalendrierPage(),
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
          child: Navigationbarboutton(userId: widget.userId),
        ),
      ),
    );
  }
}
