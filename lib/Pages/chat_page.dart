import 'package:emotion_app/services/chatbot_service.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ChatbotService chatbotService = ChatbotService();

  final List<Map<String, String>> messages = [
    {
      'role' : 'bot',
      'text': "Bonjour 👋, je suis là pour t'écouter. Comment te sens‑tu ?",
    },
  ];  


  bool en_cours = false;

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    
    if(text.isEmpty || en_cours) return;

    controller.clear();
    
    setState(() {
      messages.add({
        'role' : 'user',
        'text' : text,
      });
      en_cours = true;
    });

    try{
      final reply = await chatbotService.sendMessage(text);

      setState(() {
        messages.add({
          'role' : 'bot',
          'text' : reply,
        });
        
      });

    }
    catch(e){

      setState(() {
        messages.add({
          'role' : 'bot',
          'text' : "Erreur : impossible de contacter le chatbot.",
        });
        
      });
    }
    finally{
      setState(() {
        en_cours = false;
      });
    }
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }
    //
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chatbot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index){
                final msg = messages[index];
                final isUser = msg['role'] == 'user' ;

                return Align(
                  alignment: isUser? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser? const Color.fromARGB(255, 203, 183, 239) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if(en_cours)
            Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Ecris ton message...",
                      border: OutlineInputBorder(),
                    ) ,
                    onSubmitted: (_) => sendMessage(),
                  )
                ),

                SizedBox(width: 8,),
                IconButton(
                  onPressed: sendMessage, 
                  icon: Icon(Icons.send)
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}