import 'dart:async';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatma_elorbany_absent/firbase/FirebaseFunctions.dart';
import 'package:fatma_elorbany_absent/models/Magmo3amodel.dart';
import 'package:fatma_elorbany_absent/models/Studentmodel.dart';
import 'package:fatma_elorbany_absent/models/absancemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  List<Studentmodel> filteredStudentsList = [];

  bool? isAttendanceStarted;
  int? numberofstudents;

  late bool isStudentInList;
  late String? lastTimeDate;
  late String? lastTimeDay;

  final ValueNotifier<bool> _controller = ValueNotifier(false);

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
        await _addStudentToPresent(intent.student, intent.realStudentId);
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
      student.numberOfAbsentDays = (student.numberOfAbsentDays ?? 0) + 1;

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
      Studentmodel student, String realStudentId) async {
    // 1. Check if already present
    if (attendStudents.any((s) => s.id == student.id)) {
      await _playErrorSound();
      emit(AbsentError("This student is already in the attendance list."));
      return;
    }

    // 2. Update in-memory lists (create new lists to trigger UI updates)

    // 2. Update in-memory lists (create new lists to trigger UI updates)
    attendStudents = attendStudents..add(student);

    // Ensure that the student is removed from the absentee list after attending
    studentsList = studentsList..removeWhere((s) => s.id == student.id);
    print(studentsList.toString());

    filteredStudentsList = studentsList;
    print(filteredStudentsList.toString());

    // 3. Emit state immediately so UI updates fast
    emit(AbsenceFetched());

    // 4. Prepare absence model with updated lists
    final absenceModel = AbsenceModel(
      attendStudents: attendStudents,
      date: selectedDateStr,
      numberOfStudents: numberofstudents,
      absentStudents: studentsList,
    );
    await updateStudentAttendance(student, realStudentId);

    try {
      // 5. Update Firestore with merge option to avoid overwriting other fields
      await Firebasefunctions.updateAbsenceByDateInSubcollection(
        selectedDay,
        magmo3aModel.id,
        selectedDateStr,
        absenceModel,
      );
    } catch (e) {
      // 6. Handle Firestore errors gracefully
      emit(AbsentError("Failed to update attendance in database: $e"));
    }

    // 7. Mark attendance started
    isAttendanceStarted = true;
    _playCorrectSound();
    print("✅ Playing correct sound for ${student.name}");
    emit(ScanSuccess(student));
  }

  Future<void> updateStudentAttendance(
      Studentmodel student, String studentId) async {
    // Update local fields
    student.numberOfAttendantDays = (student.numberOfAttendantDays ?? 0) + 1;
    student.numberOfAbsentDays = ((student.numberOfAbsentDays ?? 0) - 1)
        .clamp(0, double.infinity)
        .toInt();
    student.lastDayStudentCame = selectedDay;
    student.lastDateStudentCame = selectedDateStr;

    // Update Firestore
    await Firebasefunctions.updateStudentInCollection(
      magmo3aModel.grade ?? "",
      studentId,
      student,
    );
  }

  Future<void> _scanQrcode(BuildContext context) async {
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

              if (scannedValue != null) {
                final student = await Firebasefunctions.getStudentById(
                  magmo3aModel.grade ?? "",
                  scannedValue,
                );

                if (student != null &&
                    student.hisGroupsId?.contains(magmo3aModel.id) == true) {
                  await _addStudentToPresent(student, scannedValue);
                } else {
                  _playErrorSound();
                  if (!isClosed)
                    emit(ScanError(
                      student == null
                          ? "Student not found!"
                          : "Student is not part of this group!",
                    ));
                }
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

  Future<void> _playCorrectSound() async {
    await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
  }

  Future<void> _playErrorSound() async {
    await _audioPlayer.play(AssetSource(
      'sounds/error.mp3',
    ));
  }

  @override
  Future<void> close() {
    _studentsSubscription?.cancel(); // مهم جداً
    return super.close();
  }
}
