import 'package:emotion_app/services/chatbot_service.dart';
import 'package:emotion_app/services/cycleService.dart';
import 'package:emotion_app/services/profile_service.dart';
import 'package:emotion_app/services/statistiqueService.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  const ChatPage({
    super.key,
    required this.userId,
    });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final ChatbotService chatbotService = ChatbotService();
  final ProfileService profilService = ProfileService();

  String prenom="";

  @override
  void initState(){
    super.initState();
    loadPrenom();
  }

  Future<void> loadPrenom() async{
    final p = await profilService.getPrenom(widget.userId);
    setState(() {
      prenom = p;
      messages[0]['text'] = "Bonjour $prenom 👋 ! Comment vas-tu ajourd'hui ?";
    });
  }

  //String prenom = profilService.getPrenom(userId);

  final List<Map<String, String>> messages = [
    {
      'role' : 'bot',
      'text': "Bonjour 👋! Comment vas-tu aujourd'hui ?",
    },
  ];  


  bool en_cours = false;

  Map<String, dynamic> _buildStats() {
    final cycle = CycleService.instance;
    final logs = StatistiquesService.logsDeLaPeriode(
      cycle.tousLesLogs,
      PeriodeStats.semaine,
    );
    final repartition = StatistiquesService.repartitionHumeurs(logs);
    final tendances = StatistiquesService.calculerTendances(
      logs,
      cycle.tousLesLogs,
      cycle,
    );

    final symptomes = <String, int>{};
    for (final log in logs) {
      for (final symptome in log.symptomes) {
        if (symptome == 'Aucun') continue;
        symptomes[symptome] = (symptomes[symptome] ?? 0) + 1;
      }
    }

    String? symptomeFrequent;
    if (symptomes.isNotEmpty) {
      final top =
          symptomes.entries.reduce((a, b) => a.value >= b.value ? a : b);
      symptomeFrequent = top.key;
    }

    return {
      'periode': PeriodeStats.semaine.libelle.toLowerCase(),
      'nbJoursRemplis': logs.length,
      'scoreMoyen': StatistiquesService.scoreMoyen(logs),
      'sommeilMoyen': StatistiquesService.sommeilMoyen(logs),
      'totalSymptomes': StatistiquesService.totalSymptomes(logs),
      'humeurDominante':
          repartition.isNotEmpty ? repartition.first.libelle : null,
      'symptomeFrequent': symptomeFrequent,
      'phaseActuelle': cycle.phasePour(DateTime.now()).name,
      'tendances': tendances.map((t) => t.texte).toList(),
    };
  }

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
      final stats = _buildStats();
      final reply = await chatbotService.sendMessage(text, stats);
      setState(() {
        messages.add({
          'role' : 'bot',
          'text' : reply,
        });
        
      });

    }
    catch(e){
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        messages.add({
          'role' : 'bot',
          'text' : "Erreur chatbot : $errorMessage",
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
