import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

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

      final dateInscription = DateTime.tryParse(user.createdAt) ?? DateTime.now();

      return {
        'nom': data['nom'] ?? '',
        'prenom': data['prenom'] ?? '',
        'genre': data['genre'] ?? 'autre',
        'date_naissance': data['date_naissance'],
        'objective': data['objective'] ?? '',
        'image_url': data['image_url'],
        'jours_membre': DateTime.now().difference(dateInscription).inDays,
      };
    } catch (e) {
      print('ERREUR getProfil: $e');
      return null;
    }
  }

  Future<void> updateProfil(Map<String, dynamic> fields) async {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Utilisateur non connecté");
  
      try {
        await supabase
            .from('profiles')
            .update(fields)
            .eq('id', user.id);
      } catch (e, st) {
        print('EXCEPTION updateProfil: $e');
        print('STACK: $st');
        rethrow;
      }
  }



  Future<String> uploadPhoto(File imageFile) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");
 
    final ext = imageFile.path.split('.').last.toLowerCase();
    final fileName = '${user.id}/avatar.$ext';
 
    try {
    // Lit les bytes directement avant l'upload
// car ici le chemin de l'image est sauvegarder temporairement dans le téléphone et peut être supprimé après l'upload, contrairement à l'URL qui doit rester accessible.  
          final bytes = await imageFile.readAsBytes();
      // Upload dans le bucket "avatars"
      await supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
          );
 
      // Récupère l'URL publique
      final publicUrl =
          supabase.storage.from('avatars').getPublicUrl(fileName);
 
      // Met à jour image_url dans profiles
      await updateProfil({'image_url': publicUrl});
 
      return publicUrl;
    } catch (e, st) {
      print('EXCEPTION uploadPhoto: $e');
      print('STACK: $st');
      rethrow;
    }
  }

  Future<void> supprimerPhoto() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");
 
    try {
      // Supprime les deux formats possibles
      await supabase.storage.from('avatars').remove([
        '${user.id}/avatar.jpg',
        '${user.id}/avatar.png',
        '${user.id}/avatar.jpeg',
      ]);
 
      await updateProfil({'image_url': null});
    } catch (e) {
      print('EXCEPTION supprimerPhoto: $e');
    }
  }


  
} 