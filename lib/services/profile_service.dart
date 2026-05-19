import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<void> saveProfil({
    required String nom,
    required String prenom,
    required DateTime datenaissance,
    required String genre,
    String? objective,
    String? imageUrl,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception("Utilisateur non connecté");
    }

    final userId = user.id;

    try {
      await supabase
          .from('profiles')
          .upsert(
        {
          'id': userId,
          'nom': nom,
          'prenom': prenom,
          'date_naissance': datenaissance.toIso8601String(),
          'genre': genre,
          'objective': objective,
          'image_url': imageUrl,
        },
        onConflict: 'id',
      );
    } catch (e, st) {
      print('EXCEPTION: $e');
      print('STACK: $st');
    }
  }

  Future<bool> profilExiste(String userID) async {
    final user = supabase.auth.currentUser;

    if (user == null) return false;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userID)
        .maybeSingle();

    return data != null;
  }

  Future<String> getPrenom(String userId) async {
    final user = supabase.auth.currentSession;

    if (user == null) return "";

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return "";

    return data['prenom'];
  }

  Future<Map<String, dynamic>?> getProfil(String userId) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) return null;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;

      final createdAt = user.createdAt;
      DateTime dateInscription;
      if (createdAt is String) {
        dateInscription = DateTime.tryParse(createdAt) ?? DateTime.now();
      } else {
        dateInscription = DateTime.now();
      }

      final joursMembre = DateTime.now().difference(dateInscription).inDays;

      return {
        'nom': data['nom'] ?? '',
        'prenom': data['prenom'] ?? '',
        'genre': data['genre'] ?? 'autre',
        'image_url': data['image_url'],
        'jours_membre': joursMembre,
      };
    } catch (e) {
      print('ERREUR getProfil: $e');
      return null;
    }
  }
} 