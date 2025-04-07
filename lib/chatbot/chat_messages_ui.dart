import 'package:flutter/material.dart';
import './chatbot_message_ui.dart';  
import './user_message_ui.dart';  

class ChatMessages extends StatelessWidget {
  final List<Map<String, String>> chatMessages;
  final ScrollController scrollController;

  ChatMessages({required this.chatMessages, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16),
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        bool isUser = chatMessages[index]['sender'] == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: isUser
              ? UserMessage(message: chatMessages[index]['message']!)  
              : ChatbotMessage(message: chatMessages[index]['message']!), 
        );
      },
    );
  }
}
