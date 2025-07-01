import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatma_elorbany_absent/firbase/FirebaseFunctions.dart';
import 'package:fatma_elorbany_absent/models/Magmo3amodel.dart';
import 'package:fatma_elorbany_absent/models/Studentmodel.dart';
import 'package:fatma_elorbany_absent/models/absancemodel.dart';
import 'package:flutter/material.dart';

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

  final AudioPlayer _audioPlayer = AudioPlayer();
  final searchController = TextEditingController();
  List<Studentmodel> studentsList = [];
  List<Studentmodel> attendStudents = [];
  bool? isAttendanceStarted;

  List<Studentmodel> filteredStudentsList = [];
  final _controller = ValueNotifier<bool>(false);
  int? numberofstudents;
  late bool isStudentInList;
  late String? lastTimeDate;
  late String? lastTimeDay;

  Future<void> handleIntent(AbsentIntent intent) async {
    switch (intent) {
      case FetchAbsence():
        await _fetchAbsence();
      case StartTakingAttendance():
        _startTakingAbsence();
      case AddStudentToPresent():
        await _addStudent(intent.student, intent.realStudentId);
      case ScanQrIntent():
        await _scanQrAndAddStudent(intent.context);
      case SearchStudent():
        _searchStudent(intent.query);
    }
  }

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  Future<void> _playErortSound() async {
    await _audioPlayer.play(AssetSource('sounds/error.mp3'));
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

        emit(AbsenceFetched());
      } else {
        await _fetchStudentsList();
      }
    } catch (e) {
      emit(AbsentError('Error fetching absence record: $e'));
    }
  }

  Future<void> _fetchStudentsList() async {
    try {
      emit(AbsentLoading());

      Stream<QuerySnapshot<Studentmodel>>? snapshotStream =
          Firebasefunctions.getStudentsByGroupId(
        magmo3aModel.grade ?? "",
        magmo3aModel.id,
      );

      snapshotStream.listen((snapshot) {
        studentsList = snapshot.docs.map((doc) => doc.data()).toList();
        filteredStudentsList = studentsList;
        isAttendanceStarted = false;

        emit(AbsenceFetched());
      });
    } catch (e) {
      emit(AbsentError("Error fetching students: $e"));
    }
  }

  Future<void> _addStudent(Studentmodel student, String realStudentId) async {
    isStudentInList = attendStudents.any((s) => s.id == student.id);
    if (isStudentInList) {
      _playErortSound();
      emit(AbsentError("This student is already in the attendance list."));
    } else {
      attendStudents.add(student);
      studentsList.removeWhere((s) => s.id == realStudentId);

      AbsenceModel absenceModel = AbsenceModel(
        attendStudents: attendStudents,
        date: selectedDateStr,
        numberOfStudents: numberofstudents,
        absentStudents: studentsList,
      );

      await Firebasefunctions.updateAbsenceByDateInSubcollection(
        selectedDay,
        magmo3aModel.id,
        selectedDateStr,
        absenceModel,
      );

      emit(StudentAddedToPresent(student));
    }
  }

  void _startTakingAbsence() async {

    for (var student in studentsList) {
      student.numberOfAbsentDays = (student.numberOfAbsentDays ?? 0) + 1;

      await Firebasefunctions.updateStudentInCollection(
        student.grade ?? "",
        student.id,
        student,
      );
      isAttendanceStarted = true;
      emit(AttendanceStarted());
    }
  }

  Future<void> updateStudentAttendanceAndAbsence(
      String grade, String studentId, Studentmodel student) async {
    student.numberOfAttendantDays = (student.numberOfAttendantDays ?? 0) + 1;
    student.numberOfAbsentDays = ((student.numberOfAbsentDays ?? 0) - 1)
        .clamp(0, double.infinity)
        .toInt();

    lastTimeDay = student.lastDayStudentCame;
    lastTimeDate = student.lastDateStudentCame;

    student.lastDayStudentCame = selectedDay;
    student.lastDateStudentCame = selectedDateStr;

    await Firebasefunctions.updateStudentInCollection(
      grade,
      studentId,
      student,
    );
  }

  Future<void> _scanQrAndAddStudent(BuildContext context) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
          onDispose: () => debugPrint("Barcode scanner disposed!"),
          hideGalleryButton: false,
          controller: MobileScannerController(
            detectionSpeed: DetectionSpeed.noDuplicates,
          ),
          onDetect: (BarcodeCapture capture) async {
            final scannedValue = capture.barcodes.first.rawValue;
            if (scannedValue != null) {
              final student = await Firebasefunctions.getStudentById(
                magmo3aModel.grade ?? "",
                scannedValue,
              );

              if (student != null &&
                  student.hisGroupsId?.contains(magmo3aModel.id) == true) {
                await _addStudent(student, scannedValue);
                await updateStudentAttendanceAndAbsence(
                  magmo3aModel.grade ?? "",
                  scannedValue,
                  student,
                );

                if (!isStudentInList) {
                  _playCorrectSound();
                  emit(ScanSuccess(student));
                }
              } else {
                _playErortSound();
                emit(ScanError(student == null
                    ? "Student not found!"
                    : "Not in this group!"));
              }
            }
          },
        ),
      ),
    );
  }

  void _searchStudent(String query) {
    if (query.isEmpty) {
      filteredStudentsList = studentsList;
    } else {
      filteredStudentsList = studentsList.where((student) {
        final studentName = student.name?.toLowerCase() ?? '';
        return studentName.contains(query.toLowerCase());
      }).toList();
    }

    emit(SearchResultsUpdated(filteredStudentsList));
  }
}
