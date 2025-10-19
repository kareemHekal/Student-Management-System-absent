import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Alertdialogs/Delete Absence.dart';
import '../colors_app.dart';
import '../firbase/FirebaseFunctions.dart';
import '../models/Magmo3amodel.dart';
import '../models/Studentmodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/absancemodel.dart';
import '../otherPages/Students attending Page.dart';
import '../otherPages/view_model/cubit.dart';

class CustomBottomSheet extends StatefulWidget {
  List<Studentmodel> filteredStudentsList = [];
  final String selectedDay;
  final Magmo3amodel magmo3aModel;
  AbsenceModel absenceModel;
  CustomBottomSheet({
    Key? key,
    required this.filteredStudentsList,
    required this.absenceModel,
    required this.magmo3aModel,
    required this.selectedDay,
  }) : super(key: key);

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  String _buildNotesForDate(Studentmodel student, String dateKey) {
    if (student.notes == null || student.notes!.isEmpty) {
      return ("There are no notes");
    }
    String? noteForSelectedDate;
    for (var note in student.notes!) {
      if (note.containsKey(dateKey)) {
        noteForSelectedDate = note[dateKey];
        break;
      }
    }
    if (noteForSelectedDate != null) {
      return ("$noteForSelectedDate");
    } else {
      return ("No notes for $dateKey");
    }
  }

  pw.TextDirection _getTextDirection(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text)
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;
  }

  _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("fonts/NotoKufiArabic-Regular.ttf");
    final pw.Font font = pw.Font.ttf(fontData);

    final String selectedDate = widget.absenceModel.date;
    final String day = widget.selectedDay;
    final String grade = widget.magmo3aModel.grade ?? 'Unknown Grade';
    final String time =
        widget.magmo3aModel.time?.format(context) ?? 'Unknown Time';
    final int absentCount = widget.filteredStudentsList.length;

    List<List<Studentmodel>> studentChunks = [];
    for (var i = 0; i < absentCount; i += 2) {
      studentChunks.add(
        widget.filteredStudentsList
            .sublist(i, i + 2 > absentCount ? absentCount : i + 2),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  "Attendance Report",
                  style: pw.TextStyle(font: font, fontSize: 16),
                  textDirection: _getTextDirection("Attendance Report"),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Date: $selectedDate",
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection: _getTextDirection("Date: $selectedDate"),
                ),
                pw.Text(
                  "Day: $day",
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection: _getTextDirection(day),
                ),
                pw.Text(
                  "Grade: $grade",
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection: _getTextDirection(grade),
                ),
                pw.Text(
                  "Time: $time",
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection: _getTextDirection(time),
                ),
                pw.Text(
                  "Total Absent Students: $absentCount",
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection:
                  _getTextDirection("Total Absent Students: $absentCount"),
                ),
                pw.Divider(),
                if (studentChunks.isNotEmpty)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Expanded(
                        child: _buildStudentCard(studentChunks[0][0], font),
                      ),
                      if (studentChunks[0].length > 1)
                        pw.Expanded(
                          child: _buildStudentCard(studentChunks[0][1], font),
                        ),
                    ],
                  ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );


    for (var i = 1; i < studentChunks.length; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      child: _buildStudentCard(studentChunks[i][0], font),
                    ),
                    if (studentChunks[i].length > 1)
                      pw.Expanded(
                        child: _buildStudentCard(studentChunks[i][1], font),
                      ),
                  ],
                ),
                pw.SizedBox(height: 20),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildStudentCard(Studentmodel student, pw.Font font) {
    String note = _buildNotesForDate(student, widget.absenceModel.date);
    return pw.Container(
      margin: const pw.EdgeInsets.all(8.0),
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text("Name: ",
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection: _getTextDirection("Name: ")),
              pw.Text(student.name ?? 'Unnamed Student',
                  style: pw.TextStyle(font: font, fontSize: 12),
                  textDirection:
                  _getTextDirection(student.name ?? 'Unnamed Student')),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text("Phone Number: ${student.phoneNumber ?? 'N/A'}",
              style: pw.TextStyle(font: font, fontSize: 12),
              textDirection:
              _getTextDirection(student.phoneNumber ?? 'N/A')),
          pw.SizedBox(height: 8),
          pw.Text("Mother Number: ${student.motherPhone ?? 'N/A'}",
              style: pw.TextStyle(font: font, fontSize: 12),
              textDirection:
              _getTextDirection(student.motherPhone ?? 'N/A')),
          pw.SizedBox(height: 8),
          pw.Text("Father Number: ${student.fatherPhone ?? 'N/A'}",
              style: pw.TextStyle(font: font, fontSize: 12),
              textDirection:
              _getTextDirection(student.fatherPhone ?? 'N/A')),
          pw.Text("Grade: ${student.grade ?? 'N/A'}",
              style: pw.TextStyle(font: font, fontSize: 12),
              textDirection:
              _getTextDirection(student.grade ?? 'N/A')),
          pw.SizedBox(height: 8),
          pw.Text(note,
              style: pw.TextStyle(font: font, fontSize: 12),
              textDirection: _getTextDirection(note)),
        ],
      ),
    );
  }


  Future<void> fixAttendanceCounts() async {

    try {
      // ✅ 1. Update absent students (subtract 1 from numberOfAbsentDays)
      for (var student in widget.absenceModel.absentStudents) {
        if (student.numberOfAbsentDays != null && student.numberOfAbsentDays! > 0) {
          student.numberOfAbsentDays = student.numberOfAbsentDays! - 1;
        } else {
          student.numberOfAbsentDays = 0;
        }

        await Firebasefunctions.updateStudentInCollection(
          widget.magmo3aModel.grade ?? "",
          student.id,
          student,
        );
      }

      // ✅ 2. Update attended students (subtract 1 from numberOfAttendantDays)
      for (var student in widget.absenceModel.attendStudents) {
        if (student.numberOfAttendantDays != null && student.numberOfAttendantDays! > 0) {
          student.numberOfAttendantDays = student.numberOfAttendantDays! - 1;
        } else {
          student.numberOfAttendantDays = 0;
        }

        await Firebasefunctions.updateStudentInCollection(
          widget.magmo3aModel.grade ?? "",
          student.id,
          student,
        );
      }

    } catch (e) {
      print("$e ⛔⛔⛔");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: app_colors.ligthGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Divider(
              height: 3,
              thickness: 5,
              color: app_colors.orange,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  imagePath: "assets/icon/printer.png",
                  label: "Print",
                  onPressed: () async {
                    if (widget.filteredStudentsList.isNotEmpty) {
                      await _generatePdf(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("No Absent Students",
                                style: TextStyle(color: app_colors.orange)),
                            content: Text("There are no absent students to export.",
                                style: TextStyle(color: app_colors.ligthGreen)),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK',
                                    style: TextStyle(color: app_colors.orange)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                            backgroundColor: app_colors.ligthGreen,
                          );
                        },
                      );
                    }
                  },
                ),
                _buildIconButton(
                  imagePath: "assets/icon/done.png",
                  label: "Students attending",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentsAttending(
                          absenceModel: AbsenceModel(
                            date: widget.absenceModel.date,
                            numberOfStudents:
                            widget.absenceModel.numberOfStudents,
                            absentStudents:
                            widget.absenceModel.absentStudents,
                            attendStudents:
                            widget.absenceModel.attendStudents,
                          ),
                          magmo3aModel: widget.magmo3aModel,
                          selectedDay: widget.selectedDay,
                        ),
                      ),
                    );
                  },
                ),
                _buildIconButton(
                  imagePath: "assets/icon/delete.png",
                  label: "Delete",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: app_colors.ligthGreen,
                        title: const Text("Delete Absence",
                            style: TextStyle(color: app_colors.orange)),
                        content: DeleteConfirmationDialogContent(
                          onConfirm: () {
                            fixAttendanceCounts();
                            Firebasefunctions.deleteAbsenceFromSubcollection(
                              widget.selectedDay,
                              widget.magmo3aModel.id,
                              widget.absenceModel.date,
                            ).catchError((error) {
                              print("Error deleting absence: $error");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                    Text('Error deleting absence: $error')),
                              );
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Image.asset(
            imagePath,
            width: 40,
            height: 40,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
