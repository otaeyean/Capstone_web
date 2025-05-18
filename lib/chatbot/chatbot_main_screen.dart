import 'package:flutter/material.dart';
import 'chat_messages_ui.dart';
import 'chat_textfield.dart';
import 'package:stockapp/server/Chatbot/chatbot_server.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

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

  List<String> fixedQuestions = [
    "주식 시작 방법은?",
    "매수/매도?",
    "투자금 설정은 어떻게 해야 적절할까?"
  ];

  final Map<String, List<String>> followUpQuestionsMap = {
    "주식 시작 방법은?": [
      "주식 계좌는 어떻게 개설하나요?",
      "처음 시작할 때 얼마가 필요해요?",
      "어떤 증권사를 선택해야 하나요?"
    ],
    "매수/매도?": [
      "매수와 매도 차이는 뭔가요?",
      "언제 매도해야 할까요?",
      "주문 방법은 어떻게 되나요?"
    ],
    "투자금 설정은 어떻게 해야 적절할까?": [
      "초보는 얼마부터 시작하면 좋을까요?",
      "분산 투자는 왜 필요한가요?",
      "리스크 관리는 어떻게 하나요?"
    ],
    "주식 계좌는 어떻게 개설하나요?": [
      "비대면으로도 개설 가능할까요?",
      "신분증만 있으면 되나요?",
      "계좌 개설 후 바로 거래 가능한가요?"
    ],
    "처음 시작할 때 얼마가 필요해요?": [
      "적은 금액으로도 수익 날 수 있나요?",
      "수수료는 얼마나 드나요?",
      "ETF부터 시작해도 되나요?"
    ],
    // 계속 추가 가능
  };

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

    // 질문 클릭 시 후속 질문으로 고정질문 변경
    List<String> followUps = followUpQuestionsMap[message] ?? [];

    setState(() {
      if (followUps.isNotEmpty) {
        followUps.shuffle();
        fixedQuestions = followUps.take(3).toList();
      } else {
        fixedQuestions = [
          "주식 시작 방법은?",
          "매수/매도?",
          "투자금 설정은 어떻게 해야 적절할까?"
        ];
      }
    });
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
body: Container(
  color: Color(0xFFF5F5F5), // 앱바 아래 배경 흰색
  child: Column(
    children: [
      // 🔁 동적으로 바뀌는 고정 질문
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
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: fixedQuestions.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(fixedQuestions[index]),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _addUserMessage(fixedQuestions[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // 🧠 챗봇 메시지 UI
      Expanded(
        child: ChatMessages(
          chatMessages: chatMessages,
          scrollController: _scrollController,
        ),
      ),

      // 💬 사용자 입력창
      ChatInput(
        messageController: _messageController,
        onSendMessage: _addUserMessage,
      ),
    ],
  ),
),

    );
  }
}
