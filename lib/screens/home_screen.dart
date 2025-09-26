import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import 'qibla_screen.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final PrayerTimes? cached;
  const HomeScreen({Key? key, this.cached}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimes? _prayerTimes;
  bool _loading = false;
  String _locationText = 'Unknown';

  @override
  void initState() {
    super.initState();
    if (widget.cached != null) _prayerTimes = widget.cached;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAndSchedule());
  }

  Future<void> _fetchAndSchedule() async {
    setState(() => _loading = true);
    try {
      Position pos = await LocationService.getLocation();
      setState(() => _locationText = '${pos.latitude.toStringAsFixed(3)}, ${pos.longitude.toStringAsFixed(3)}');
      final pt = await PrayerService.fetchPrayerTimes(pos.latitude, pos.longitude);
      setState(() => _prayerTimes = pt);
      // schedule notifications (convert times to DateTimes)
      Map<String, DateTime> dtMap = {};
      final today = DateTime.now();
      _prayerTimes!.times.forEach((k, v) {
        final parts = v.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]); // handles '05:10 (GMT)'
        dtMap[k] = DateTime(today.year, today.month, today.day, hour, minute);
      });

      // load enabled toggles
      final prefs = await SharedPreferences.getInstance();
      Map<String, bool> enabled = {
        'Fajr': prefs.getBool('rem_Fajr') ?? true,
        'Dhuhr': prefs.getBool('rem_Dhuhr') ?? true,
        'Asr': prefs.getBool('rem_Asr') ?? true,
        'Maghrib': prefs.getBool('rem_Maghrib') ?? true,
        'Isha': prefs.getBool('rem_Isha') ?? true,
      };
      await NotificationService.schedulePrayerNotifications(dtMap, enabled);
    } catch (e) {
      print('Error fetch: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildList() {
    if (_prayerTimes == null) return Text('No prayer times yet');
    return Column(
      children: _prayerTimes!.times.entries.map((e) {
        return ListTile(
          leading: Icon(Icons.access_time, color: Colors.cyanAccent),
          title: Text(e.key, style: TextStyle(color: Colors.white)),
          trailing: Text(e.value, style: TextStyle(color: Colors.white70)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Prayer Companion'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.compass_calibration),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QiblaScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location: $_locationText', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 12),
                  Text(_prayerTimes?.dateReadable ?? '', style: TextStyle(color: Colors.white60)),
                  SizedBox(height: 8),
                  _buildList(),
                  Spacer(),
                  ElevatedButton.icon(
                    icon: Icon(Icons.refresh),
                    label: Text('Refresh prayer times'),
                    onPressed: _fetchAndSchedule,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ],
              ),
            ),
    );
  }
}
