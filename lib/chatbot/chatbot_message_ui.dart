import 'package:flutter/material.dart';

class ChatbotMessage extends StatefulWidget {
  final String message;
  final bool isHistory;

  ChatbotMessage({required this.message, this.isHistory = false});

  @override
  _ChatbotMessageState createState() => _ChatbotMessageState();
}

class _ChatbotMessageState extends State<ChatbotMessage> {
  String _displayedMessage = '';
  int _index = 0;
  late List<String> _messageList;

  @override
  void initState() {
    super.initState();
    _messageList = widget.message.split('');
    _displayMessage();
  }

  void _displayMessage() {
    Future.delayed(Duration(milliseconds: 50), () {
      if (_index < _messageList.length) {
        setState(() {
          _displayedMessage += _messageList[_index];
          _index++;
        });
        _displayMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, 
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(Icons.smart_toy, color: Colors.white, size: 24),
        ),
        SizedBox(width: 8), 
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 225, 227, 230), 
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _displayedMessage,
            style: TextStyle(fontSize: 16, color: Colors.black),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
