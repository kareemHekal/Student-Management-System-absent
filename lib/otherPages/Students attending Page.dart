import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../cards/StudentWidget.dart';
import '../colors_app.dart';
import '../firbase/FirebaseFunctions.dart';
import '../loading_alert/run_with_loading.dart';
import '../models/Magmo3amodel.dart';
import '../models/Studentmodel.dart';
import '../models/absence_model.dart';
import '../models/day_record.dart';
import 'AbssentPage.dart';

class StudentsAttending extends StatefulWidget {
  AbsenceModel absenceModel;
  final String selectedDay;
  final Magmo3amodel magmo3aModel;

  StudentsAttending(
      {required this.absenceModel,
      required this.magmo3aModel,
      required this.selectedDay,
      super.key});

  @override
  _StudentsAttendingState createState() => _StudentsAttendingState();
}

class _StudentsAttendingState extends State<StudentsAttending> {
  late List<Studentmodel> filteredStudents;
  final TextEditingController _searchController = TextEditingController();

  Future<void> addStudentToList(grade, id) async {
    Studentmodel? student = await Firebasefunctions.getStudentById(
      grade,
      id,
    );

    if (student != null) {
      setState(() {
        widget.absenceModel.absentStudents.add(student);
      });
      AbsenceModel absenceModel = AbsenceModel(
        attendStudents: widget.absenceModel.attendStudents,
        date: widget.absenceModel.date,
        numberOfStudents: widget.absenceModel.numberOfStudents,
        absentStudents: widget.absenceModel.absentStudents,
      );
      Firebasefunctions.updateAbsenceByDateInSubcollection(widget.selectedDay,
          widget.magmo3aModel.id, widget.absenceModel.date, absenceModel);
    }
  }

  @override
  void initState() {
    super.initState();
    filteredStudents = widget.absenceModel.attendStudents;
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = widget.absenceModel.attendStudents
          .where((student) =>
              student.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => AbsentPage(
                    selectedDay: widget.selectedDay,
                    magmo3aModel: widget.magmo3aModel,
                    selectedDateStr: widget.absenceModel.date,
                  ),
                ),
                (route) => false,
              );
            },
            icon: Icon(Icons.arrow_back_ios, color: app_colors.orange),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: app_colors.green,
          title: Image.asset(
            "assets/images/logo.png",
            height: 100,
            width: 90,
          ),
          toolbarHeight: 110,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(130),
            child: Container(
              decoration: BoxDecoration(
                color: app_colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              padding: EdgeInsets.only(bottom: 10, left: 15, right: 15),
              child: Column(
                children: [
                  TextFormField(
                    style: TextStyle(color: app_colors.green),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'ابحث عن طالب',
                      hintStyle: TextStyle(color: app_colors.green),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: app_colors.orange, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: app_colors.orange, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: app_colors.orange),
                        onPressed: () {
                          _searchController.clear();
                          _filterStudents('');
                        },
                      ),
                    ),
                    cursorColor: app_colors.green,
                    controller: _searchController,
                    onChanged: (value) {
                      _filterStudents(value);
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'عدد الطلاب الحاضرين: ${filteredStudents.length}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Center(child: Image.asset("assets/images/logo.png")),
            ),
            filteredStudents.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لا يوجد طلاب حاضرين',
                          style: TextStyle(
                            fontSize: 18,
                            color: app_colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      var student = filteredStudents[index];
                      return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('تأكيد استرجاع الطالب',
                                        style:
                                            TextStyle(color: Colors.blue[900])),
                                    content: Text(
                                        'هل أنت متأكد أنك تريد استرجاع هذا الطالب؟',
                                        style:
                                            TextStyle(color: Colors.blue[800])),
                                    actions: [
                                      TextButton(
                                        child: Text('إلغاء',
                                            style: TextStyle(
                                                color: Colors.blue[400])),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text('استرجاع',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        onPressed: () async {
                                          runWithLoading(context, () async {
                                            try {
                                              // إضافة للغياب
                                              widget.absenceModel.absentStudents
                                                  .add(student);

                                              // حذف من الحضور
                                              widget.absenceModel.attendStudents
                                                  .removeWhere(
                                                (s) => s.id == student.id,
                                              );

                                              // تحديث countingAbsentDays
                                              student.countingAbsentDays ??= [];
                                              student.countingAbsentDays!.add(
                                                DayRecord(
                                                  date:
                                                      widget.absenceModel.date,
                                                  day: widget.selectedDay,
                                                ),
                                              );

                                              // حذف من countingAttendedDays
                                              student.countingAttendedDays ??=
                                                  [];
                                              student.countingAttendedDays!
                                                  .removeWhere(
                                                (dayRecord) =>
                                                    dayRecord.date ==
                                                        widget.absenceModel
                                                            .date &&
                                                    dayRecord.day ==
                                                        widget.selectedDay,
                                              );

                                              // تحديث الطالب في الفايربيس
                                              await Firebasefunctions
                                                  .updateStudentInCollection(
                                                widget.magmo3aModel.grade ?? "",
                                                student.id,
                                                student,
                                              );

                                              // إنشاء موديل الغياب الجديد
                                              final absenceModel = AbsenceModel(
                                                attendStudents: widget
                                                    .absenceModel
                                                    .attendStudents,
                                                absentStudents: widget
                                                    .absenceModel
                                                    .absentStudents,
                                                date: widget.absenceModel.date,
                                                numberOfStudents: widget
                                                    .absenceModel
                                                    .numberOfStudents,
                                              );

                                              // تحديث الغياب في الفايربيس
                                              await Firebasefunctions
                                                  .updateAbsenceByDateInSubcollection(
                                                widget.selectedDay,
                                                widget.magmo3aModel.id,
                                                widget.absenceModel.date,
                                                absenceModel,
                                              );

                                              // تحديث UI
                                              _filterStudents('');
                                              if (mounted) setState(() {});
                                              // عرض SnackBar للنجاح
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      '✅ تم تحديث حضور ${student.name} بنجاح!',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                    duration: const Duration(
                                                      seconds: 1,
                                                    ),
                                                  ),
                                                );
                                              }
                                              // إغلاق الصفحة بعد قليل حتى يظهر SnackBar
                                              await Future.delayed(
                                                const Duration(
                                                    milliseconds: 800),
                                              );
                                              if (!context.mounted) return;
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              // طباعة الخطأ
                                              debugPrint(
                                                "❌ ERROR while updating attendance: $e",
                                              );

                                              if (!context.mounted) return;

                                              // عرض SnackBar عند الخطأ
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'حدث خطأ أثناء التحديث: $e',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                    backgroundColor: Colors.green[50],
                                  );
                                },
                              );
                            },
                            child: StudentWidget(
                              magmo3aModel: widget.magmo3aModel,
                              selectedDateStr: widget.absenceModel.date,
                              selectedDate: widget.selectedDay,
                              grade: student.grade,
                              studentModel: student,
                            ),
                          ));
                    },
                  ),
          ],
        ));
  }
}
