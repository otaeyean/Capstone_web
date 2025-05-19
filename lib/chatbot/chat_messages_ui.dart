import 'package:flutter/material.dart';
import './chatbot_message_ui.dart'; // 여기 ChatbotMessage 있음
import './user_message_ui.dart';   // 사용자 메시지 따로 만들었을 경우 사용

class ChatMessages extends StatelessWidget {
  final List<Map<String, String>> chatMessages;
  final ScrollController scrollController;

  const ChatMessages({
    required this.chatMessages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatMessages.length,
      padding: const EdgeInsets.symmetric(horizontal: 220, vertical: 12.0),
      itemBuilder: (context, index) {
        final message = chatMessages[index];
        final isUser = message['sender'] == 'user';

        if (isUser) {
          // 유저 메시지는 기본 스타일로 출력
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                message['message'] ?? '',
                style: const TextStyle(fontSize: 14.5),
              ),
            ),
          );
        } else {
          // 챗봇 메시지는 아이콘 포함된 ChatbotMessage 위젯으로 출력
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ChatbotMessage(
              message: message['message'] ?? '',
              isHistory: true,
            ),
          );
        }
      },
    );
  }
}
