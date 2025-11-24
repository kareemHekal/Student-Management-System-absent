import 'dart:async';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../firbase/FirebaseFunctions.dart';
import '../../loading_alert/run_with_loading.dart';
import '../../models/Magmo3amodel.dart';
import '../../models/Studentmodel.dart';
import '../../models/absence_model.dart';
import '../../models/day_record.dart';
import 'intent.dart';
import 'states.dart';

class AbsentCubit extends Cubit<AbsentState> {
  final Magmo3amodel magmo3aModel;
  final String selectedDateStr;
  final String selectedDay;

  AbsentCubit({
    required this.magmo3aModel,
    required this.selectedDateStr,
    required this.selectedDay,
  }) : super(AbsentInitial());

  final searchController = TextEditingController();

  List<Studentmodel> studentsList = [];
  List<Studentmodel> attendStudents = [];
  List<Studentmodel> filteredStudentsList = [];

  bool? isAttendanceStarted;
  int? numberofstudents;

  late bool isStudentInList;

  // ------------------- HANDLE INTENT -------------------
  Future<void> handleIntent(AbsentIntent intent) async {
    switch (intent.runtimeType) {
      case FetchAbsence:
        await _fetchAbsence();
        break;

      case StartTakingAttendance:
        await _startTakingAbsence();
        break;

      case AddStudentToPresent:
        final i = intent as AddStudentToPresent;
        await _addStudentToPresent(i.student, i.realStudentId, i.context);
        break;

      case ScanQrIntent:
        final i = intent as ScanQrIntent;
        await _scanQrcode(i.context);
        break;

      case SearchStudent:
        final i = intent as SearchStudent;
        _searchStudent(i.query);
        break;
    }
  }

  // ------------------- FETCH ABSENCE -------------------
  Future<void> _fetchAbsence() async {
    emit(AbsentLoading());

    try {
      final absentRecord = await Firebasefunctions.getAbsenceByDate(
        selectedDay,
        magmo3aModel.id,
        selectedDateStr,
      );

      if (absentRecord != null) {
        studentsList = absentRecord.absentStudents;
        attendStudents = absentRecord.attendStudents;
        numberofstudents = absentRecord.numberOfStudents;
        filteredStudentsList = studentsList;
        isAttendanceStarted = true;
        emit(AttendanceStarted());
      } else {
        await _fetchStudentsList();
      }
    } catch (e) {
      emit(AbsentError('Error fetching absence record: $e'));
    }
  }

  // ------------------- FETCH STUDENTS LIST -------------------
  Future<void> _fetchStudentsList() async {
    emit(AbsentLoading());
    try {
      final snapshot = await Firebasefunctions.getStudentsByGroupIdOnce(
        magmo3aModel.grade ?? "",
        magmo3aModel.id,
      );

      studentsList = snapshot.docs.map((doc) => doc.data()).toList();
      filteredStudentsList = studentsList;
      numberofstudents = studentsList.length;
      isAttendanceStarted = false;
      emit(AbsenceFetched());

      emit(AbsenceFetched());
    } catch (e) {
      emit(AbsentError("Error fetching students: $e"));
    }
  }

  // ------------------- START ATTENDANCE -------------------
  Future<void> _startTakingAbsence() async {
    emit(AbsentLoading());

    for (var student in studentsList) {
      student.countingAbsentDays ??= [];
      student.countingAbsentDays!
          .add(DayRecord(date: selectedDateStr, day: selectedDay));
      await Firebasefunctions.updateStudentInCollection(
        student.grade ?? "",
        student.id,
        student,
      );
    }

    isAttendanceStarted = true;

    final absenceModel = AbsenceModel(
      attendStudents: attendStudents,
      date: selectedDateStr,
      numberOfStudents: studentsList.length,
      absentStudents: studentsList,
    );

    await Firebasefunctions.updateAbsenceByDateInSubcollection(
      selectedDay,
      magmo3aModel.id,
      selectedDateStr,
      absenceModel,
    );

    emit(AttendanceStarted());
  }

  // ------------------- ADD STUDENT TO PRESENT -------------------
  Future<void> _addStudentToPresent(
      Studentmodel student, String realStudentId, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (attendStudents.any((s) => s.id == student.id)) {
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('⚠️ تم تسجيل حضوره من قبل.'),
          backgroundColor: Colors.orange,
          duration: Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    attendStudents.add(student);
    studentsList.removeWhere((s) => s.id == student.id);
    filteredStudentsList = studentsList;
    emit(AbsenceFetched());

    final absenceModel = AbsenceModel(
      attendStudents: attendStudents,
      date: selectedDateStr,
      numberOfStudents: numberofstudents,
      absentStudents: studentsList,
    );

    try {
      await updateStudentAttendance(student, realStudentId);
      await Firebasefunctions.updateAbsenceByDateInSubcollection(
        selectedDay,
        magmo3aModel.id,
        selectedDateStr,
        absenceModel,
      );

      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('✅ تم تسجيل حضور ${student.name} بنجاح!'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('❌ فشل في تحديث الحضور: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    isAttendanceStarted = true;
    emit(ScanSuccess(student));
  }

  Future<void> updateStudentAttendance(
      Studentmodel student, String studentId) async {
    student.countingAttendedDays ??= [];
    student.countingAttendedDays!
        .add(DayRecord(date: selectedDateStr, day: selectedDay));

    student.countingAbsentDays ??= [];
    student.countingAbsentDays!.removeWhere((dayRecord) =>
        dayRecord.date == selectedDateStr && dayRecord.day == selectedDay);

    await Firebasefunctions.updateStudentInCollection(
      magmo3aModel.grade ?? "",
      studentId,
      student,
    );
  }

  // ------------------- SCAN QR -------------------
  Future<void> _scanQrcode(BuildContext context) async {
    MobileScannerController _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: this,
          child: AiBarcodeScanner(
            onDispose: () => debugPrint("Barcode scanner disposed!"),
            hideGalleryButton: false,
            controller: _scannerController,
            onDetect: (BarcodeCapture capture) async {
              _scannerController.stop();
              await runWithLoading(context, () async {
                final scannedValue = capture.barcodes.first.rawValue;
                if (scannedValue == null) return;

                scaffoldMessenger.clearSnackBars();

                final student = await Firebasefunctions.getStudentById(
                  magmo3aModel.grade ?? "",
                  scannedValue,
                );

                if (student != null &&
                    student.hisGroupsId?.contains(magmo3aModel.id) == true) {
                  await _addStudentToPresent(student, scannedValue, context);
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        student == null
                            ? "لم يتم العثور على الطالب!"
                            : "الطالب ليس ضمن هذه المجموعة!",
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(milliseconds: 800),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
              _scannerController.start();
            },
          ),
        ),
      ),
    );
  }

  // ------------------- SEARCH STUDENT -------------------
  void _searchStudent(String query) {
    filteredStudentsList = query.isEmpty
        ? studentsList
        : studentsList
            .where((student) => (student.name ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

    emit(SearchResultsUpdated(filteredStudentsList));
  }
}
