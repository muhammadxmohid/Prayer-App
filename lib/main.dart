import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'services/prayer_service.dart';
import 'models/prayer_times.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // timezone init for notifications
  await NotificationService.init();

  final cached = await PrayerService.loadCached();
  runApp(MyApp(cached: cached));
}

class MyApp extends StatelessWidget {
  final PrayerTimes? cached;
  MyApp({this.cached});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Prayer Companion',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(primary: Colors.cyanAccent),
      ),
      home: SplashWrapper(cached: cached),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  final PrayerTimes? cached;
  SplashWrapper({this.cached});
  @override
  _SplashWrapperState createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1200), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(cached: widget.cached)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.track_changes, size: 72, color: Colors.cyanAccent),
          SizedBox(height: 12),
          Text('My Prayer Companion', style: TextStyle(color: Colors.white, fontSize: 18)),
        ]),
      ),
    );
  }
}
