import 'package:flutter/material.dart';

class FrequentlyAskedWidget extends StatelessWidget {
  final List<String> questions;
  final void Function(String) onQuestionTap;

  const FrequentlyAskedWidget({
    Key? key,
    required this.questions,
    required this.onQuestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(questions[index]),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => onQuestionTap(questions[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
