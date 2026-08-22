import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';

class AiChatScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const AiChatScreen({super.key, required this.currentUser});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final ai = AiAssistantService();
  final controller = TextEditingController();
  List<Map<String,String>> messages = [];
  bool loading = false;

  void send() async {
    if(controller.text.isEmpty) return;
    String q = controller.text;
    setState((){ messages.insert(0, {'role':'user','text':q}); loading=true; controller.clear(); });
    var res = await ai.askSmart(q, widget.currentUser);
    setState((){ messages.insert(0, {'role':'ai','text':res['text']!}); loading=false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اسأل ميتاموت - سكرتيرك ${widget.currentUser['name']}')),
      body: Column(
        children: [
          Expanded(child: ListView.builder(reverse:true, itemCount: messages.length, itemBuilder: (c,i){
            bool isUser = messages[i]['role']=='user';
            return Align(alignment: isUser? Alignment.centerRight: Alignment.centerLeft,
              child: Container(margin: EdgeInsets.all(8), padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: isUser? Colors.blue: Colors.grey[800], borderRadius: BorderRadius.circular(12)),
                child: Text(messages[i]['text']!, style: TextStyle(color: Colors.white))));
          })),
          if(loading) LinearProgressIndicator(),
          Padding(padding: EdgeInsets.all(8), child: Row(children: [
            Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: 'اسأل عن الحضور، المبيعات...'))),
            IconButton(icon: Icon(Icons.send), onPressed: send)
          ]))
        ],
      ),
    );
  }
}