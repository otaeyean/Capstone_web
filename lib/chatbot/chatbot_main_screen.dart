import 'package:flutter/material.dart';
import 'chat_messages_ui.dart';
import 'chat_textfield.dart';
import 'package:lottie/lottie.dart';
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
    if (message.isEmpty) return;
    _sendMessageToServer(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Center(
                  child: Lottie.asset(
                    'assets/lottie/hello.json',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: Column(
              children: [
                Expanded(
                  child: ChatMessages(
                    chatMessages: chatMessages,
                    scrollController: _scrollController,
                  ),
                ),
                ChatInput(
                  messageController: _messageController,
                  onSendMessage: _addUserMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
