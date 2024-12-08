import 'Studentmodel.dart';

class AbsenceModel {
  final String date; // The date of the absence record.
  int? numberOfStudents; // Total number of students in the record.
  List<Studentmodel> absentStudents; // List of absent students.
  List<Studentmodel> attendStudents; // List of attending students.

  AbsenceModel({
    required this.date,
    required this.numberOfStudents,
    required this.absentStudents,
    required this.attendStudents,
  });

  // Factory constructor to create an instance from JSON.
  factory AbsenceModel.fromJson(Map<String, dynamic> json) {
    return AbsenceModel(
      date: json['date'] ?? '', // Default to an empty string if date is null.
      numberOfStudents: json['numberOfStudents'] ?? 0, // Default to 0 if null.
      absentStudents: (json['absentStudents'] as List<dynamic>? ?? [])
          .map((studentJson) => Studentmodel.fromJson(studentJson as Map<String, dynamic>))
          .toList(),
      attendStudents: (json['attendStudents'] as List<dynamic>? ?? [])
          .map((studentJson) => Studentmodel.fromJson(studentJson as Map<String, dynamic>))
          .toList(),
    );
  }

  // Method to convert an instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'numberOfStudents': numberOfStudents,
      'absentStudents': absentStudents.map((student) => student.toJson()).toList(),
      'attendStudents': attendStudents.map((student) => student.toJson()).toList(),
    };
  }
}
