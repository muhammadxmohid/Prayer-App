import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart';

class PrayerService {
  static const String _cacheKey = 'cached_prayer_times';

  // Aladhan API: pass lat, lng, method=2 (Muslim World League) or choose method
  static Future<PrayerTimes> fetchPrayerTimes(double lat, double lng) async {
    final now = DateTime.now();
    final url = Uri.parse('http://api.aladhan.com/v1/timings/${now.toUtc().toIso8601String().split('T').first}'
        '?latitude=$lat&longitude=$lng&method=2'); // method toggle if needed

    final resp = await http.get(url).timeout(Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw ('Failed to fetch prayer times');
    }
    final data = json.decode(resp.body);
    final timings = data['data']['timings'] as Map<String, dynamic>;
    // pick required times
    Map<String, String> times = {
      'Fajr': timings['Fajr'],
      'Dhuhr': timings['Dhuhr'],
      'Asr': timings['Asr'],
      'Maghrib': timings['Maghrib'],
      'Isha': timings['Isha'],
    };

    final readable = data['data']['date']['readable'] ?? now.toString();
    final pt = PrayerTimes(dateReadable: readable, times: times);
    await _cache(pt);
    return pt;
  }

  static Future<void> _cache(PrayerTimes pt) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_cacheKey, json.encode(pt.toJson()));
  }

  static Future<PrayerTimes?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_cacheKey);
    if (s == null) return null;
    final m = json.decode(s);
    return PrayerTimes.fromJson(Map<String, dynamic>.from(m));
  }
}
