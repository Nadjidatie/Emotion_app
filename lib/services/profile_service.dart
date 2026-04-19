import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<void> saveProfil({
    required String nom,
    required String prenom,
    required DateTime datenaissance,
    required String genre,
    String? objective,
  }) async{
    final user = supabase.auth.currentUser;
  
    if (user == null) {
      throw Exception("Utilisateur non connecté");
    }

    final userId = user.id;

    try {
      final userId = user.id;
      final res = await Supabase.instance.client
        .from('profiles')
        .upsert
      (
        {
          'id': userId,
          'nom': nom,
          'prenom': prenom,
          'date_naissance': datenaissance.toIso8601String(),
          'genre': genre,
          'objective': objective,
        },
        onConflict: 'id',
      );
    
    
      

    }
    catch (e, st) {
      print('EXCEPTION: $e');
      print('STACK: $st');
    }




  }




  Future<bool> profilExiste(String userID) async {
    final user = supabase.auth.currentUser;

    if (user == null ){
      return false;

    }

    final data = await supabase 
      .from('profiles')
      .select()
      .eq('id', userID)
      .maybeSingle();

    return data != null;
  }

} 