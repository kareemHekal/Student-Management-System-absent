import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
//functions================================================================================================================================
  String _buildNotesForDate(Studentmodel student, String dateKey) {
    if (student.notes == null || student.notes!.isEmpty) {
      return ("There are no notes");
    }

    // Find note for the selected date
    String? noteForSelectedDate;
    for (var note in student.notes!) {
      if (note.containsKey(dateKey)) {
        noteForSelectedDate = note[dateKey];
        break; // Stop once we find the note for the selected date
      }
    }

    // Display the note for the selected date
    if (noteForSelectedDate != null) {
      return (" $noteForSelectedDate");
    } else {
      return ("No notes for $dateKey");
    }
  }

  _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("fonts/NotoKufiArabic-Regular.ttf");
    final pw.Font font = pw.Font.ttf(fontData);

    // Access information from the widget and the filtered list
    final String selectedDate = widget.absenceModel.date;
    final String day = widget.selectedDay;
    final String grade = widget.magmo3aModel.grade ?? 'Unknown Grade';
    final String time =
        widget.magmo3aModel.time?.format(context) ?? 'Unknown Time';
    final int absentCount = widget.filteredStudentsList.length;

    // Create a list of students to display in pairs
    List<List<Studentmodel>> studentChunks = [];
    for (var i = 0; i < absentCount; i += 2) {
      studentChunks.add(
        widget.filteredStudentsList
            .sublist(i, i + 2 > absentCount ? absentCount : i + 2),
      );
    }

    // Create the first page with the attendance report
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Content over the background
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Header information
                  pw.Text("Attendance Report",
                      style: pw.TextStyle(font: font, fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Text("Date: $selectedDate",
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text("Day: $day",
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text("Grade: $grade",
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text("Time: $time",
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Text("Total Absent Students: $absentCount",
                      style: pw.TextStyle(font: font, fontSize: 12)),
                  pw.Divider(),

                  // Show first 2 students on the first page
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
                  pw.SizedBox(height: 20), // Space after the first row
                ],
              ),
            ],
          );
        },
      ),
    );

    // Create additional pages for remaining students
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
                pw.SizedBox(height: 20), // Space after the row
              ],
            );
          },
        ),
      );
    }

    // Print the document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildStudentCard(Studentmodel student, pw.Font font) {
    String note = _buildNotesForDate(student, widget.absenceModel.date);
    return pw.Container(
      margin: const pw.EdgeInsets.all(8.0), // Space around each card
      padding: const pw.EdgeInsets.all(16.0), // Internal padding of the card
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.white, // Background color of the card set to white
        border: pw.Border.all(
            color: PdfColors.black, width: 2), // Set border color to black
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Name with split label and value
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Text(
                "Name: ",
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
              pw.Text(
                student.name ?? 'Unnamed Student',
                style: pw.TextStyle(font: font, fontSize: 12),
                textDirection: pw
                    .TextDirection.rtl, // Set text direction to RTL for Arabic
              ),
            ],
          ),
          pw.SizedBox(height: 8), // Space between name and next field

          // Phone Number
          pw.Text(
            "Phone Number: ${student.phoneNumber ?? 'N/A'}",
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 8), // Space between phone number and next field

          // Mother Number
          pw.Text(
            "Mother Number: ${student.motherPhone ?? 'N/A'}",
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 8), // Space between mother number and next field

          // Father Number
          pw.Text(
            "Father Number: ${student.fatherPhone ?? 'N/A'}",
            style: pw.TextStyle(font: font, fontSize: 12),
          ),

          // Grade
          pw.Text(
            "Grade: ${student.grade ?? 'N/A'}",
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 8), // Space between father number and next field
          pw.Text(
            textDirection: pw.TextDirection.rtl,
            note,
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ],
      ),
    );
  }

  //functions================================================================================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // ارتفاع الـ Bottom Sheet
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
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  imagePath: "assets/icon/printer.png", // مسار صورة الطباعة
                  label: "Print",
                  onPressed: () async {
                    if (widget.filteredStudentsList.isNotEmpty) {
                      await _generatePdf(context);
                    } else {
                      // Show AlertDialog when there are no absent students
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "No Absent Students",
                              style: TextStyle(
                                  color: app_colors.orange), // Orange title
                            ),
                            content: Text(
                              "There are no absent students to export.",
                              style: TextStyle(
                                  color: app_colors
                                      .ligthGreen), // Light green message
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                      color: app_colors
                                          .orange), // Orange button text
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                            backgroundColor: app_colors
                                .ligthGreen, // Light green background for the dialog
                          );
                        },
                      );
                    }
                  },
                ),
                _buildIconButton(
                  imagePath: "assets/icon/done.png", // مسار صورة الإنهاء
                  label: "Students attending",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentsAttending(
                                absenceModel: AbsenceModel(
                                    date: widget.absenceModel.date,
                                    numberOfStudents: widget.absenceModel.numberOfStudents,
                                    absentStudents: widget.absenceModel.absentStudents,
                                    attendStudents: widget.absenceModel.attendStudents),
                                magmo3aModel: widget.magmo3aModel,
                                selectedDay: widget.selectedDay,
                              )),
                      // Removes all previous routes
                    );
                  },
                ),
                _buildIconButton(
                  imagePath: "assets/icon/delete.png", // مسار صورة الإنهاء
                  label: "Delete",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: app_colors.ligthGreen,
                        title: const Text(
                          "Delete Absence",
                          style: TextStyle(color: app_colors.orange),
                        ),
                        content: DeleteConfirmationDialogContent(
                          onConfirm: () {
                            Firebasefunctions.deleteAbsenceFromSubcollection(
                              widget.selectedDay,
                              widget.magmo3aModel.id,
                              widget.absenceModel.date,
                            ).catchError((error) {
                              // Handle the error
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
        SizedBox(height: 8), // مسافة بين الصورة والنص
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
