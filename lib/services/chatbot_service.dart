import 'package:supabase_flutter/supabase_flutter.dart';

class ChatbotService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> sendMessage(String message) async{
    final response = await supabase.functions.invoke(
      'chatbot',
      body: {
        'message': message,
      },
    );

    //  print('===== DEBUG CHATBOT =====');
    //   print('status = ${response.status}');
    //   print('data = ${response.data}');
    //   print('=========================');

    final data = response.data;

    if(data == null){
      throw Exception('Reponse vide');

    }

    if(data is Map && data['reply']!= null ){
      return data['reply'] as String;
    }

    throw Exception('Réponse invalide');
  
    
  }

  
}