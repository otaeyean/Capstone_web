import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../server/login/login_server.dart';
import 'package:stockapp/main.dart';
import './signup.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoggedIn = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('nickname') != null;
    });
  }

  Future<void> _login() async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text.trim();

    if (nickname.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    final result = await AuthService.login(nickname, password);

    if (result['success']) {
      final balance = result['balance'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nickname 님 어서오세요!'))
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('nickname', nickname);
      prefs.setDouble('balance', balance.toDouble());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '로그인',
          style: TextStyle(fontFamily: "GmarketBold"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: Text('회원가입', style: TextStyle(color: Colors.black)),
          ),
        ],
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
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: "GmarketBold",
                ),
                children: [
                  TextSpan(text: ' 반갑습니다!\n '),
                  TextSpan(
                    text: '로그인',
                    style: TextStyle(
                      color: Color(0xFF67CA98 ),
                      fontFamily: "GmarketBold",
                    ),
                  ),
                  TextSpan(text: '을 해주세요.\n\n'),
                ],
              ),
            ),
            Text('아이디', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: '아이디를 입력해주세요',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('비밀번호', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '비밀번호를 입력해주세요',
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
                  onPressed: _login,
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "GmarketBold",
                    ),
                  ),
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
