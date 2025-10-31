/// Represents a single attendance or absent day
class DayRecord {
  final String date; // e.g., "2025-10-28"
  final String day; // e.g., "Monday"

  DayRecord({
    required this.date,
    required this.day,
  });

  /// Create an instance from JSON
  factory DayRecord.fromJson(Map<String, dynamic> json) {
    return DayRecord(
      date: json['date'] ?? '',
      day: json['day'] ?? '',
    );
  }

  /// Convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
    };
  }

  /// Copy with optional new values
  DayRecord copyWith({
    String? date,
    String? day,
  }) {
    return DayRecord(
      date: date ?? this.date,
      day: day ?? this.day,
    );
  }

  @override
  String toString() => 'DayRecord(date: $date, day: $day)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayRecord && other.date == date && other.day == day;
  }
}
