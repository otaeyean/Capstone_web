import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final password = _passwordController.text.trim();
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    final url = Uri.parse('http://withyou.me:8080/signup');
    final body = jsonEncode({
      "userId": nickname,
      "password": password,
    });

    print('✅ 요청 Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 성공!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final error = jsonDecode(response.body)['message'] ?? '회원가입 실패!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 60),
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(fontSize: 30, color: Colors.black, fontFamily: "GmarketBold"),
                children: [
                  TextSpan(text: ' 회원님의\n '),
                  TextSpan(
                    text: '계정',
                    style: TextStyle(color: Color(0xFF67CA98 ), fontFamily: "GmarketBold"),
                  ),
                  TextSpan(text: '을 만들어주세요.\n\n', style: TextStyle(fontFamily: "GmarketBold")),
                ],
              ),
            ),
            Text('아이디', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '아이디',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text('PW', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '비밀번호',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 150),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signUp,
                  child: Text('회원가입 하기', style: TextStyle(color: Colors.white, fontFamily: "GmarketBold")),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF67CA98 ),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
