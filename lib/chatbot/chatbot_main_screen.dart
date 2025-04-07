import 'package:flutter/material.dart';
import 'chat_messages_ui.dart';
import 'chat_textfield.dart';
import 'package:stockapp/server/Chatbot/chatbot_server.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  List<Map<String, String>> chatMessages = [];
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final ChatbotService _chatbotService = ChatbotService();
  String userId = '';

  final List<String> fixedQuestions = [
    "주식 시작 방법은?",
    "매수/매도?",
    "투자금 설정은 어떻게 해야 적절할까?"
  ];

  @override
  void initState() {
    super.initState();
    _getUserNickname().then((_) {
      _fetchChatHistory();
    });
  }

  Future<void> _getUserNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('nickname') ?? 'defaultUser';
    });
  }

  Future<void> _fetchChatHistory() async {
    if (userId.isEmpty) return;
    final url = Uri.parse('http://withyou.me:8080/chatbot/chat-log?userName=$userId&size=6');

    try {
      final response = await http.get(url, headers: {'accept': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> content = data['content'];
        content.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

        List<Map<String, String>> loadedMessages = [];
        for (int i = 0; i < content.length; i++) {
          var chat = content[i];
          String sender = (i % 2 == 0) ? 'user' : 'bot';
          loadedMessages.add({'sender': sender, 'message': chat['message']});
        }

        if (loadedMessages.isEmpty) {
          loadedMessages.add({'sender': 'bot', 'message': '무엇을 도와드릴까요?'});
        }

        setState(() {
          chatMessages = loadedMessages;
        });

        _scrollToBottom();
      } else {
        print('Failed to load chat history: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching chat history: $error');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessageToServer(String message) async {
    if (userId.isEmpty) return;

    try {
      String botResponse = await _chatbotService.sendMessage(message, userId);

      setState(() {
        chatMessages.add({'sender': 'user', 'message': message});
        chatMessages.add({'sender': 'bot', 'message': botResponse});
      });

      _scrollToBottom();
    } catch (error) {
      print('Error: $error');
    }
  }

  void _addUserMessage(String message) {
    if (message.isNotEmpty) {
      _sendMessageToServer(message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7CC993), Color(0xFF22B379)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '위드유 챗봇입니다!',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            SizedBox(width: 10),
            Icon(Icons.waving_hand, size: 30, color: Colors.white),
          ],
        ),
      ),
      body: Column(
        children: [
          //고정질문부분
                  Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7CC993), Color(0xFF22B379)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "자주 묻는 질문",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                ListView.builder(
                  shrinkWrap: true, // 스크롤 설정
                  itemCount: fixedQuestions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white, // 질문 카드 배경색
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(fixedQuestions[index]),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _addUserMessage(fixedQuestions[index]);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ChatMessages(chatMessages: chatMessages, scrollController: _scrollController),
          ),
          ChatInput(
            messageController: _messageController,
            onSendMessage: (message) {
              _addUserMessage(message);
            },
          ),
        ],
      ),
    );
  }
}
