import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, bool> toggles = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      toggles.forEach((k, v) {
        toggles[k] = p.getBool('rem_$k') ?? true;
      });
    });
  }

  _save(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('rem_$key', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Settings'), backgroundColor: Colors.black87),
      body: ListView(
        children: toggles.keys.map((k) {
          return SwitchListTile(
            title: Text('$k reminder', style: TextStyle(color: Colors.white)),
            value: toggles[k]!,
            onChanged: (v) {
              setState(() => toggles[k] = v);
              _save(k, v);
            },
            activeColor: Colors.cyanAccent,
          );
        }).toList(),
      ),
    );
  }
}
