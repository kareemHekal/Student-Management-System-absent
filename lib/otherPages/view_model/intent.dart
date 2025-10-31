import 'package:flutter/material.dart';
import '../../models/Studentmodel.dart';

sealed class AbsentIntent {}

class FetchAbsence extends AbsentIntent {}

class StartTakingAttendance extends AbsentIntent {}

class AddStudentToPresent extends AbsentIntent {
  final Studentmodel student;
  final String realStudentId;
  final BuildContext context;


  AddStudentToPresent({
    required this.student,
    required this.context,
    required this.realStudentId,
  });
}

class ScanQrIntent extends AbsentIntent {
  final BuildContext context;

  ScanQrIntent({required this.context});
}

class SearchStudent extends AbsentIntent {
  final String query;

  SearchStudent({required this.query});
}
