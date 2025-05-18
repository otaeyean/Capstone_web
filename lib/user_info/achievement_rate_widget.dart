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
  bool isLoadingGoal = false;
  final TextEditingController _goalController = TextEditingController();

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
    if (rate != null) {
      _achievementRate = rate;
    }
  });
}

  Future<void> _saveProfitGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('profitGoal_${widget.userId}', goal);
  }

  Future<void> _fetchAchievementRate() async {
    final rate = await ProfitGoalService.getAchievementRate(widget.userId);
    if (rate != null) {
      setState(() {
        _achievementRate = rate;
      });
    }
  }

  void _showProfitGoalInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("목표 수익률 입력", style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: _goalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "예) 20.0"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("취소", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              final parsed = double.tryParse(_goalController.text);
              if (parsed != null) {
                final success = await ProfitGoalService.updateProfitGoal(widget.userId, parsed);
                if (success) {
                  await _saveProfitGoal(parsed);
                  final newRate = await ProfitGoalService.getAchievementRate(widget.userId);
                  if (newRate != null) {
                    setState(() {
                      _profitGoal = parsed;
                      _achievementRate = newRate;
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('목표 수익률 설정에 실패했습니다.')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: Text("확인", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "달성률 (목표 수익률: ${_profitGoal.toStringAsFixed(1)}%)",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showProfitGoalInputDialog(context),
                ),
              ],
            ),
            SizedBox(
              height: 60,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double fullWidth = constraints.maxWidth;
                  double halfWidth = fullWidth / 2;

                  double rate = _achievementRate.clamp(-100, 100);
                  bool isPositive = rate >= 0;
                  double barWidth = (rate.abs() / 100) * (isPositive ? fullWidth : halfWidth);
                  double barLeft = isPositive ? 0 : halfWidth - barWidth;
                  double labelCenter = barLeft + barWidth / 2;
                  double textWidth = 80;

                  double labelLeft = (labelCenter - textWidth / 2).clamp(0, fullWidth - textWidth);

                  return Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // // 기준선 
                      // if (!isPositive)
                      //   Positioned(
                      //     left: halfWidth - 1,
                      //     top: 0,
                      //     bottom: 0,
                      //     child: Container(
                      //       width: 0.5,
                      //       color: Colors.grey[500],
                      //     ),
                      //   ),

                      // 수익률 바
                      Positioned(
                        left: barLeft,
                        child: Container(
                          height: 20,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: isPositive ? Colors.red : Colors.blue,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(10),
                              right: isPositive ? Radius.circular(10) : Radius.zero,
                            ),
                          ),
                        ),
                      ),

                      // 기준선 아래에 0 텍스트
                      if (!isPositive)
                        Positioned(
                          left: halfWidth - 6,
                          top: 24,
                          child: Text(
                            "0",
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ),

                      // 달성률 텍스트 
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
                                color: _achievementRate >= 0 ? Colors.red : Colors.blue,
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
      ),
    );
  }
}
