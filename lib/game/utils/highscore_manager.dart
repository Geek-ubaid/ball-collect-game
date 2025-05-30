import 'package:shared_preferences/shared_preferences.dart';

class HighScoreManager {
  static const String _highScoreKey = 'highScore';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int currentHighScore = await getHighScore();
    if (score > currentHighScore) {
      await prefs.setInt(_highScoreKey, score);
    }
  }
}