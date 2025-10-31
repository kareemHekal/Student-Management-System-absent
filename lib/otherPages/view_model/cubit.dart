import 'dart:async';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../firbase/FirebaseFunctions.dart';
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
  late String? lastTimeDate;
  late String? lastTimeDay;

  StreamSubscription<QuerySnapshot<Studentmodel>>? _studentsSubscription;

  Future<void> handleIntent(AbsentIntent intent) async {
    switch (intent) {
      case FetchAbsence():
        await _fetchAbsence();
        break;

      case StartTakingAttendance():
        _startTakingAbsence();
        break;
      case AddStudentToPresent():
        await _addStudentToPresent(
            intent.student, intent.realStudentId, intent.context);
        break;

      case ScanQrIntent():
        await _scanQrcode(intent.context);
        break;

      case SearchStudent():
        _searchStudent(intent.query);
        break;
    }
  }

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

  Future<void> _fetchStudentsList() async {
    emit(AbsentLoading());
    try {
      final snapshotStream = Firebasefunctions.getStudentsByGroupId(
        magmo3aModel.grade ?? "",
        magmo3aModel.id,
      );

      _studentsSubscription = snapshotStream.listen((snapshot) {
        if (isClosed) return;

        studentsList = snapshot.docs.map((doc) => doc.data()).toList();
        filteredStudentsList = studentsList;
        if (isAttendanceStarted != true) {
          isAttendanceStarted = false;
          emit(AbsenceFetched());
        }
      });
    } catch (e) {
      emit(AbsentError("Error fetching students: $e"));
    }
  }

  void _startTakingAbsence() async {
    _studentsSubscription?.cancel();
    emit(AbsentLoading());

    for (var student in studentsList) {
      student.countingAbsentDays ??= [];
      student.countingAbsentDays!.add(
        DayRecord(date: selectedDateStr, day: selectedDay),
      );

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

  Future<void> _addStudentToPresent(
    Studentmodel student,
    String realStudentId,
    BuildContext context,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Check if already present
    if (attendStudents.any((s) => s.id == student.id)) {
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('⚠️ ${student.name} تم تسجيل حضوره من قبل.'),
          backgroundColor: Colors.orange,
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Update in-memory lists
    attendStudents = attendStudents..add(student);
    studentsList = studentsList..removeWhere((s) => s.id == student.id);
    filteredStudentsList = studentsList;

    emit(AbsenceFetched());

    // 3. Prepare absence model
    final absenceModel = AbsenceModel(
      attendStudents: attendStudents,
      date: selectedDateStr,
      numberOfStudents: numberofstudents,
      absentStudents: studentsList,
    );

    try {
      // 4. Update Firestore
      await updateStudentAttendance(student, realStudentId);
      await Firebasefunctions.updateAbsenceByDateInSubcollection(
        selectedDay,
        magmo3aModel.id,
        selectedDateStr,
        absenceModel,
      );

      // 5. Success feedback
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
      // 6. Firestore error handling
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

    // 7. Mark attendance started
    isAttendanceStarted = true;
    emit(ScanSuccess(student));
  }

  Future<void> updateStudentAttendance(
      Studentmodel student, String studentId) async {

    student.countingAttendedDays ??= [];
    student.countingAttendedDays!.add(
      DayRecord(date: selectedDateStr, day: selectedDay),
    );


     student.countingAbsentDays ??= [];
    student.countingAbsentDays!.remove(
      DayRecord(date: selectedDateStr, day: selectedDay),
    );

    await Firebasefunctions.updateStudentInCollection(
      magmo3aModel.grade ?? "",
      studentId,
      student,
    );
  }

  Future<void> _scanQrcode(BuildContext context) async {
    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: this,
          child: AiBarcodeScanner(
            onDispose: () {
              debugPrint("Barcode scanner disposed!");
            },
            hideGalleryButton: false,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (BarcodeCapture capture) async {
              final String? scannedValue = capture.barcodes.first.rawValue;
              if (scannedValue == null) return;

              // ✅ Instantly remove any previous snackbar
              scaffoldMessenger.clearSnackBars();

              final student = await Firebasefunctions.getStudentById(
                magmo3aModel.grade ?? "",
                scannedValue,
              );

              if (student != null &&
                  student.hisGroupsId?.contains(magmo3aModel.id) == true) {
                await _addStudentToPresent(student, scannedValue, context);
              } else {
                final msg = student == null
                    ? "لم يتم العثور على الطالب!"
                    : "الطالب ليس ضمن هذه المجموعة!";

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Colors.red,
                    duration: const Duration(milliseconds: 800),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _searchStudent(String query) {
    if (query.isEmpty) {
      filteredStudentsList = studentsList;
    } else {
      filteredStudentsList = studentsList.where((student) {
        final name = student.name?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    }

    emit(SearchResultsUpdated(
      filteredStudentsList,
    ));
  }

  @override
  Future<void> close() {
    _studentsSubscription?.cancel();
    return super.close();
  }
}
