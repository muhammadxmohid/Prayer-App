class PrayerTimes {
  final String dateReadable;
  final Map<String, String> times; // e.g. 'Fajr': '05:10'
  PrayerTimes({required this.dateReadable, required this.times});

  Map<String, dynamic> toJson() => {
    'dateReadable': dateReadable,
    'times': times,
  };

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      dateReadable: json['dateReadable'],
      times: Map<String, String>.from(json['times']),
    );
  }
}
