import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/server/userInfo/profit_goal_server.dart';

class AchievementRateWidget extends StatefulWidget {
  final String userId;

  const AchievementRateWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _AchievementRateWidgetState createState() => _AchievementRateWidgetState();
}

class _AchievementRateWidgetState extends State<AchievementRateWidget> {
  double _profitGoal = 0.0;
  double _achievementRate = 0.0;
  final TextEditingController _goalController = TextEditingController();
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeGoalAndRate();
  }

Future<void> _initializeGoalAndRate() async {
  final prefs = await SharedPreferences.getInstance();
  final savedGoal = prefs.getDouble('profitGoal_${widget.userId}') ?? 0.0;
  final rate = await ProfitGoalService.getAchievementRate(widget.userId);

  setState(() {
    _profitGoal = savedGoal;
    _goalController.text = savedGoal > 0 ? savedGoal.toStringAsFixed(1) : '';
    _achievementRate = rate ?? 0.0;
    _errorText = null;
  });
}

  Future<void> _saveProfitGoal(String input) async {
    final parsed = double.tryParse(input);
    if (parsed == null || parsed < 0) {
      setState(() {
        _errorText = '올바른 수치(0 이상)를 입력해주세요.';
      });
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });
    final success = await ProfitGoalService.updateProfitGoal(widget.userId, parsed);
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('profitGoal_${widget.userId}', parsed);
      final newRate = await ProfitGoalService.getAchievementRate(widget.userId);
      setState(() {
        _profitGoal = parsed;
        _achievementRate = newRate ?? 0.0;
        _isSaving = false;
      });
    } else {
      setState(() {
        _errorText = '목표 수익률 설정에 실패했습니다.';
        _isSaving = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "달성률",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // 텍스트와 간격 조절용
          // 목표 수익률 표시 추가 부분
          Text(
            "현재 사용자가 설정한 목표 수익률 : ${_goalController.text.isEmpty ? '-' : _goalController.text}%",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _goalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '목표 수익률 (%)',
                    errorText: _errorText,
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  onSubmitted: (value) {
                    _saveProfitGoal(value);
                  },
                  enabled: !_isSaving,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          _saveProfitGoal(_goalController.text);
                        },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.blue, width: 2),
                    padding: EdgeInsets.zero,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 60,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double fullWidth = constraints.maxWidth;
                double halfWidth = fullWidth / 2;

                double rate = _achievementRate.clamp(-100, 100);
                bool isPositive = rate >= 0;
                double barWidth =
                    (rate.abs() / 100) * (isPositive ? fullWidth : halfWidth);
                double barLeft = isPositive ? 0 : halfWidth - barWidth;
                double labelCenter = barLeft + barWidth / 2;
                double textWidth = 80;

                double labelLeft =
                    (labelCenter - textWidth / 2).clamp(0, fullWidth - textWidth);

                return Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Positioned(
                      left: barLeft,
                      child: Container(
                        height: 20,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: isPositive ? Colors.red : Colors.blue,
                          borderRadius: BorderRadius.horizontal(
                            left: const Radius.circular(10),
                            right: isPositive
                                ? const Radius.circular(10)
                                : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                    if (!isPositive)
                      Positioned(
                        left: halfWidth - 6,
                        top: 24,
                        child: Text(
                          "0",
                          style:
                              TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    Positioned(
                      left: labelLeft,
                      top: 36,
                      child: SizedBox(
                        width: textWidth,
                        child: Center(
                          child: Text(
                            "${_achievementRate.toStringAsFixed(2)}%",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _achievementRate >= 0
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

}
