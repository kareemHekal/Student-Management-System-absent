import 'Magmo3amodel.dart';
import 'day_record.dart';

class Studentmodel {
  String id;
  String? name;
  String? grade;
  String? gender;
  String? phoneNumber;
  String? motherPhone;
  String? fatherPhone;
  List<Map<String, String>>? notes;
  List<Magmo3amodel>? hisGroups;
  List<String>? hisGroupsId;
  String? note;
  List<DayRecord>? countingAttendedDays;
  List<DayRecord>? countingAbsentDays;
  String? dateofadd;

  Studentmodel({
    this.id = "",
    this.name,
    this.grade,
    this.gender,
    this.phoneNumber,
    this.motherPhone,
    this.fatherPhone,
    this.notes,
    this.hisGroups,
    this.hisGroupsId,
    this.note,
    this.countingAttendedDays,
    this.countingAbsentDays,
    this.dateofadd,
  });

  factory Studentmodel.fromJson(Map<String, dynamic> json) {
    return Studentmodel(
      id: json['id'] ?? "",
      name: json['name'],
      gender: json['gender'],
      grade: json['grade'],
      phoneNumber: json['phonenumber'],
      motherPhone: json['mothernumber'],
      fatherPhone: json['fatherphone'],
      note: json['note'],
      dateofadd: json['dateofadd'],
      notes: json["notes"] != null
          ? List<Map<String, String>>.from(
          json["notes"].map((note) => Map<String, String>.from(note)))
          : [],
      hisGroups: json["hisGroups"] != null
          ? List<Magmo3amodel>.from(
          json["hisGroups"].map((group) => Magmo3amodel.fromJson(group)))
          : [],
      hisGroupsId: json["hisGroupsId"] != null
          ? List<String>.from(json["hisGroupsId"])
          : [],
      countingAttendedDays: json["countingAttendedDays"] != null
          ? List<DayRecord>.from(
          json["countingAttendedDays"]
              .map((day) => DayRecord.fromJson(day)))
          : [],
      countingAbsentDays: json["countingAbsentDays"] != null
          ? List<DayRecord>.from(
          json["countingAbsentDays"]
              .map((day) => DayRecord.fromJson(day)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'grade': grade,
      'phonenumber': phoneNumber,
      'mothernumber': motherPhone,
      'fatherphone': fatherPhone,
      'note': note,
      'dateofadd': dateofadd,
      'notes': notes,
      'hisGroups': hisGroups != null
          ? List<Map<String, dynamic>>.from(
          hisGroups!.map((group) => group.toJson()))
          : [],
      'hisGroupsId': hisGroupsId,

      'countingAttendedDays': countingAttendedDays != null
          ? List<Map<String, dynamic>>.from(
          countingAttendedDays!.map((day) => day.toJson()))
          : [],
      'countingAbsentDays': countingAbsentDays != null
          ? List<Map<String, dynamic>>.from(
          countingAbsentDays!.map((day) => day.toJson()))
          : [],
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
  String toString() {
    return 'Studentmodel(id: $id, name: $name, grade: $grade, phone: $phoneNumber)';
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ grade.hashCode;
}
