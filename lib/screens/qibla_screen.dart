import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';


class QiblaScreen extends StatefulWidget {
  @override
  _QiblaScreenState createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _heading; // device heading

  // Kaaba coordinates:
  final double _kaabaLat = 21.422487;
  final double _kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    FlutterCompass.events!.listen((event) {
      setState(() {
        _heading = event.heading;
      });
    });
  }

  // compute bearing from location to kaaba (degrees)
  double _bearing(double lat1, double lon1) {
    // lat, lon in degrees
    final phi1 = lat1 * (pi / 180);
    final phi2 = _kaabaLat * (pi / 180);
    final lambda1 = lon1 * (pi / 180);
    final lambda2 = _kaabaLng * (pi / 180);

    final y = sin(lambda2 - lambda1) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(lambda2 - lambda1);
    final theta = atan2(y, x);
    return ((theta * 180 / pi) + 360) % 360;
  }

  // For demo: we ask for current position from geolocator
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Qibla Compass'), backgroundColor: Colors.black87),
      body: FutureBuilder(
        future: _getPosition(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final pos = snapshot.data as Map<String, double>;
          final bearingToKaaba = _bearing(pos['lat']!, pos['lng']!);
          final deviceHeading = _heading ?? 0;
          final direction = (bearingToKaaba - deviceHeading + 360) % 360;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Point your phone so the arrow faces the Qibla', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 20),
                Transform.rotate(
                  angle: direction * (pi / 180) * -1,
                  child: Icon(Icons.navigation, size: 120, color: Colors.cyanAccent),
                ),
                SizedBox(height: 16),
                Text('Bearing to Kaaba: ${bearingToKaaba.toStringAsFixed(1)}°', style: TextStyle(color: Colors.white60)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, double>> _getPosition() async {
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return {'lat': pos.latitude, 'lng': pos.longitude};
  }
}
