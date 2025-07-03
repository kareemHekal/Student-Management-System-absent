import 'Magmo3amodel.dart';

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
  String? dateOfExplainingNotePaid;
  String? dateOfReviewingNotePaid;

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
    this.dateOfExplainingNotePaid,
    this.dateOfReviewingNotePaid,
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
          ? List<Map<String, String>>.from(json["notes"].map((note) => Map<String, String>.from(note)))
          : [],

      hisGroups: json["hisGroups"] != null
          ? List<Magmo3amodel>.from(json["hisGroups"].map((group) => Magmo3amodel.fromJson(group)))
          : [],

      hisGroupsId: json["hisGroupsId"] != null
          ? List<String>.from(json["hisGroupsId"])
          : [],

      numberOfAbsentDays: json['numberOfAbsentDays'] ?? 0,
      numberOfAttendantDays: json['numberOfAttendantDays'] ?? 0,
      lastDayStudentCame: json['lastDayStudentCame'],
      lastDateStudentCame: json['lastDateStudentCame'],
      dateOfFirstMonthPaid: json['dateOfFirstMonthPaid'],
      dateOfSecondMonthPaid: json['dateOfSecondMonthPaid'],
      dateOfThirdMonthPaid: json['dateOfThirdMonthPaid'],
      dateOfFourthMonthPaid: json['dateOfFourthMonthPaid'],
      dateOfFifthMonthPaid: json['dateOfFifthMonthPaid'],
      dateOfExplainingNotePaid: json['dateOfExplainingNotePaid'],
      dateOfReviewingNotePaid: json['dateOfReviewingNotePaid'],
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
          ? List<Map<String, dynamic>>.from(hisGroups!.map((group) => group.toJson()))
          : [],
      'hisGroupsId': hisGroupsId,
      'numberOfAbsentDays': numberOfAbsentDays,
      'numberOfAttendantDays': numberOfAttendantDays,
      'lastDateStudentCame': lastDateStudentCame,
      'lastDayStudentCame': lastDayStudentCame,
      'dateOfFirstMonthPaid': dateOfFirstMonthPaid,
      'dateOfSecondMonthPaid': dateOfSecondMonthPaid,
      'dateOfThirdMonthPaid': dateOfThirdMonthPaid,
      'dateOfFourthMonthPaid': dateOfFourthMonthPaid,
      'dateOfFifthMonthPaid': dateOfFifthMonthPaid,
      'dateOfExplainingNotePaid': dateOfExplainingNotePaid,
      'dateOfReviewingNotePaid': dateOfReviewingNotePaid,
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
