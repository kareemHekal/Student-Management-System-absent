
  import 'package:flutter/material.dart';

class Magmo3amodel {
  String? days;
  String? grade;
  TimeOfDay? time;
  String? userid;
  String id;


  Magmo3amodel({
    this.id = "",
    this.grade,
    this.days,
    this.time,
    this.userid,
  });

  factory Magmo3amodel.fromJson(Map<String, dynamic> json) {
    return Magmo3amodel(
      userid: json['userid'],
      days: json["days"] ?? [], // default to empty list if null
      id: json['id'] ?? "", // default to empty string if null
      grade: json["grade"],
      time: json["time"] != null
          ? TimeOfDay(
        hour: json["time"]["hour"] ?? 0, // default to 0 if null
        minute: json["time"]["minute"] ?? 0, // default to 0 if null
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid':userid,
      "days": days , // default to empty list if null
      "id": id,
      "grade": grade,
      "time": time != null
          ? {"hour": time?.hour, "minute": time?.minute}
          : null,
    };
  }
}
