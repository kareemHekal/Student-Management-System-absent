import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Alertdialogs/Delete Absence.dart';
import '../colors_app.dart';
import '../firbase/FirebaseFunctions.dart';
import '../homeScreen.dart';
import '../loading_alert/run_with_loading.dart';
import '../models/Magmo3amodel.dart';
import '../models/Studentmodel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/absence_model.dart';
import '../models/day_record.dart';
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
  String _buildNotesForDate(Studentmodel student, String dateKey) {
    if (student.notes == null || student.notes!.isEmpty) {
      return "لا توجد ملاحظات";
    }
    String? noteForSelectedDate;
    for (var note in student.notes!) {
      if (note.containsKey(dateKey)) {
        noteForSelectedDate = note[dateKey];
        break;
      }
    }
    if (noteForSelectedDate != null) {
      return noteForSelectedDate;
    } else {
      return "لا توجد ملاحظات لتاريخ $dateKey";
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
    final String grade = widget.magmo3aModel.grade ?? 'غير محدد';
    final String time =
        widget.magmo3aModel.time?.format(context) ?? 'غير محدد';
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
                  "تقرير الحضور والغياب",
                  style: pw.TextStyle(font: font, fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textDirection: pw.TextDirection.rtl,
                ),
                pw.SizedBox(height: 10),
                pw.Text("التاريخ: $selectedDate", style: pw.TextStyle(font: font, fontSize: 12)),
                pw.Text("اليوم: $day", style: pw.TextStyle(font: font, fontSize: 12)),
                pw.Text("الصف: $grade", style: pw.TextStyle(font: font, fontSize: 12)),
                pw.Text("الوقت: $time", style: pw.TextStyle(font: font, fontSize: 12)),
                pw.Text("عدد الطلاب الغائبين: $absentCount", style: pw.TextStyle(font: font, fontSize: 12)),
                pw.Divider(),
                if (studentChunks.isNotEmpty)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Expanded(child: _buildStudentCard(studentChunks[0][0], font)),
                      if (studentChunks[0].length > 1)
                        pw.Expanded(child: _buildStudentCard(studentChunks[0][1], font)),
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
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Expanded(child: _buildStudentCard(studentChunks[i][0], font)),
                      if (studentChunks[i].length > 1)
                        pw.Expanded(child: _buildStudentCard(studentChunks[i][1], font)),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildStudentCard(Studentmodel student, pw.Font font) {
    String note = _buildNotesForDate(student, widget.absenceModel.date);
    return pw.Container(
      margin: const pw.EdgeInsets.all(8.0),
      padding: const pw.EdgeInsets.all(12.0),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("الاسم: ${student.name ?? 'بدون اسم'}", style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text("رقم الهاتف: ${student.phoneNumber ?? 'غير متوفر'}", style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text("رقم الأم: ${student.motherPhone ?? 'غير متوفر'}", style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text("رقم الأب: ${student.fatherPhone ?? 'غير متوفر'}", style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text("الصف: ${student.grade ?? 'غير متوفر'}", style: pw.TextStyle(font: font, fontSize: 12)),
          pw.SizedBox(height: 4),
          pw.Text("الملاحظات: $note", style: pw.TextStyle(font: font, fontSize: 12)),
        ],
      ),
    );
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
            Divider(height: 3, thickness: 5, color: app_colors.orange),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  imagePath: "assets/icon/printer.png",
                  label: "طباعة",
                  onPressed: () async {
                    if (widget.filteredStudentsList.isNotEmpty) {
                      await _generatePdf(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: app_colors.ligthGreen,
                          title: Text("لا يوجد طلاب غائبين", style: TextStyle(color: app_colors.orange)),
                          content: Text("لا يوجد طلاب غائبين للتصدير.", style: TextStyle(color: app_colors.ligthGreen)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("موافق", style: TextStyle(color: app_colors.orange)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                _buildIconButton(
                  imagePath: "assets/icon/done.png",
                  label: "الطلاب الحاضرون",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentsAttending(
                          absenceModel: widget.absenceModel,
                          magmo3aModel: widget.magmo3aModel,
                          selectedDay: widget.selectedDay,
                        ),
                      ),
                    );
                  },
                ),
                _buildIconButton(
                  imagePath: "assets/icon/delete.png",
                  label: "حذف الغياب",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: app_colors.ligthGreen,
                        title: Text("حذف الغياب", style: TextStyle(color: app_colors.orange)),
                        content: DeleteConfirmationDialogContent(
                          onConfirm: () async {
                            await Firebasefunctions.deleteAbsenceFromSubcollection(
                              widget.selectedDay,
                              widget.magmo3aModel.id,
                              widget.absenceModel.date,
                            ).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("حدث خطأ أثناء حذف الغياب: $error")),
                              );
                            });
                            await fixAttendanceCounts();
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

  Widget _buildIconButton({required String imagePath, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Image.asset(imagePath, width: 40, height: 40),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> fixAttendanceCounts() async {
    runWithLoading(context, () async {
      try {
        // ✅ 1. Update absent students (subtract 1 from numberOfAbsentDays)
        for (var student in widget.absenceModel.absentStudents) {

          student.countingAbsentDays ??= [];

          student.countingAbsentDays!.removeWhere((dayRecord) =>
          dayRecord.date == widget.absenceModel.date &&
              dayRecord.day == widget.selectedDay);


          await Firebasefunctions.updateStudentInCollection(
            widget.magmo3aModel.grade ?? "",
            student.id,
            student,
          );

        }

        // ✅ 2. Update attended students (subtract 1 from numberOfAttendantDays)
        for (var student in widget.absenceModel.attendStudents) {
          student.countingAttendedDays ??= [];
          student.countingAttendedDays!.remove(
            DayRecord(date: widget.absenceModel.date, day: widget.selectedDay),
          );

          await Firebasefunctions.updateStudentInCollection(
            widget.magmo3aModel.grade ?? "",
            student.id,
            student,
          );
        }

        // Navigate to HomeScreen and show SnackBar after deletion
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Homescreen()),
              (route) => false, // Removes all previous routes
        );

      } catch (e) {
        print("$e ⛔⛔⛔");
      }
    });

  }

}
