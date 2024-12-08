import 'package:flutter/material.dart';

class Studentmodel {
  String id;
  String? name;
  String? grade;
  String? firstDay;
  String? secondDay;
  String? thirdDay;
  String? forthday;
  String? gender;
  String? phoneNumber;
  String? motherPhone;
  String? fatherPhone;
  List<Map<String, String>>? notes;

  // New ID fields for each day
  String? firstDayId;
  String? secondDayId;
  String? thirdDayId;
  String? fourthDayId;

  // New time fields for each day
  TimeOfDay? firstDayTime;
  TimeOfDay? secondDayTime;
  TimeOfDay? thirdDayTime;
  TimeOfDay? forthdayTime;

  String? note;
  String? dateofadd;
  int? numberOfAbsentDays;
  int? numberOfAttendantDays;
  String? lastDayStudentCame;
  String? lastDateStudentCame;
  String? dateOfFirstMonthPaid;
  String? dateOfSecondMonthPaid;
  String? dateOfThirdMonthPaid;
  String? dateOfFourthMonthPaid;
  String? dateOfFifthMonthPaid;

  Studentmodel({
    this.id = "",
    this.name,
    this.grade,
    this.firstDay,
    this.secondDay,
    this.thirdDay,
    this.forthday,
    this.gender,
    this.phoneNumber,
    this.motherPhone,
    this.fatherPhone,
    this.notes,
    this.firstDayId,
    this.secondDayId,
    this.thirdDayId,
    this.fourthDayId,
    this.firstDayTime,
    this.secondDayTime,
    this.thirdDayTime,
    this.forthdayTime,
    this.note,
    this.dateofadd,
    this.numberOfAbsentDays,
    this.numberOfAttendantDays,
    this.lastDayStudentCame,
    this.lastDateStudentCame,
    this.dateOfFirstMonthPaid,
    this.dateOfSecondMonthPaid,
    this.dateOfThirdMonthPaid,
    this.dateOfFourthMonthPaid,
    this.dateOfFifthMonthPaid,
  });

  factory Studentmodel.fromJson(Map<String, dynamic> json) {
    return Studentmodel(
      id: json['id'] ?? "",
      name: json['name'],
      gender: json['gender'],
      grade: json['grade'],
      firstDay: json['firstDay'],
      secondDay: json['secondday'],
      thirdDay: json['thirdday'],
      forthday: json['forthday'],
      phoneNumber: json['phonenumber'],
      motherPhone: json['mothernumber'],
      fatherPhone: json['fatherphone'],
      note: json['note'],
      dateofadd: json['dateofadd'],
      notes: json["notes"] != null
          ? List<Map<String, String>>.from(json["notes"].map((note) => Map<String, String>.from(note)))
          : [],
      firstDayId: json['firstdayid'],
      secondDayId: json['secondayid'],
      thirdDayId: json['thirddayid'],
      fourthDayId: json['forthdayid'],
      firstDayTime: json['firstdaytime'] != null
          ? TimeOfDay(
        hour: json['firstdaytime']['hour'] ?? 0,
        minute: json['firstdaytime']['minute'] ?? 0,
      )
          : null,
      secondDayTime: json['seconddaytime'] != null
          ? TimeOfDay(
        hour: json['seconddaytime']['hour'] ?? 0,
        minute: json['seconddaytime']['minute'] ?? 0,
      )
          : null,
      thirdDayTime: json['thirddaytime'] != null
          ? TimeOfDay(
        hour: json['thirddaytime']['hour'] ?? 0,
        minute: json['thirddaytime']['minute'] ?? 0,
      )
          : null,
      forthdayTime: json['forthdaytime'] != null
          ? TimeOfDay(
        hour: json['forthdaytime']['hour'] ?? 0,
        minute: json['forthdaytime']['minute'] ?? 0,
      )
          : null,
      numberOfAbsentDays: json['numberOfAbsentDays'] ?? 0,
      numberOfAttendantDays: json['numberOfAttendantDays'] ?? 0,
      lastDayStudentCame: json['lastDayStudentCame'],
      lastDateStudentCame: json['lastDateStudentCame'],
      dateOfFirstMonthPaid: json['dateOfFirstMonthPaid'],
      dateOfSecondMonthPaid: json['dateOfSecondMonthPaid'],
      dateOfThirdMonthPaid: json['dateOfThirdMonthPaid'],
      dateOfFourthMonthPaid: json['dateOfFourthMonthPaid'],
      dateOfFifthMonthPaid: json['dateOfFifthMonthPaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'grade': grade,
      'firstDay': firstDay,
      'secondday': secondDay,
      'thirdday': thirdDay,
      'forthday': forthday,
      'phonenumber': phoneNumber,
      'mothernumber': motherPhone,
      'fatherphone': fatherPhone,
      'note': note,
      'dateofadd': dateofadd,
      'notes': notes,
      'firstdayid': firstDayId,
      'secondayid': secondDayId,
      'thirddayid': thirdDayId,
      'forthdayid': fourthDayId,
      'firstdaytime': firstDayTime != null
          ? {'hour': firstDayTime!.hour, 'minute': firstDayTime!.minute}
          : null,
      'seconddaytime': secondDayTime != null
          ? {'hour': secondDayTime!.hour, 'minute': secondDayTime!.minute}
          : null,
      'thirddaytime': thirdDayTime != null
          ? {'hour': thirdDayTime!.hour, 'minute': thirdDayTime!.minute}
          : null,
      'forthdaytime': forthdayTime != null
          ? {'hour': forthdayTime!.hour, 'minute': forthdayTime!.minute}
          : null,
      'numberOfAbsentDays': numberOfAbsentDays,
      'numberOfAttendantDays': numberOfAttendantDays,
      'lastDateStudentCame': lastDateStudentCame,
      'lastDayStudentCame': lastDayStudentCame,
      'dateOfFirstMonthPaid': dateOfFirstMonthPaid,
      'dateOfSecondMonthPaid': dateOfSecondMonthPaid,
      'dateOfThirdMonthPaid': dateOfThirdMonthPaid,
      'dateOfFourthMonthPaid': dateOfFourthMonthPaid,
      'dateOfFifthMonthPaid': dateOfFifthMonthPaid,
    };
  }

  // Equality check
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Studentmodel &&
        other.id == id &&
        other.name == name &&
        other.grade == grade;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ grade.hashCode;
}
