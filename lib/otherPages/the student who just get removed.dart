import 'package:flutter/material.dart';
import '../cards/normalstudentcard.dart';
import '../firbase/FirebaseFunctions.dart';
import '../models/Studentmodel.dart';
import 'AbssentPage.dart';
import '../colors_app.dart';
import '../models/Magmo3amodel.dart';

class Thestudentwhojustgetremoved extends StatefulWidget {
  final String selectedDateStr;
  final String selectedDate;
  final Magmo3amodel magmo3aModel;
  Studentmodel? student;
  String? lastTimeDate;
  String? lastTimeDay;

  Thestudentwhojustgetremoved({
    required this.lastTimeDate,
    required this.lastTimeDay,
    required this.selectedDateStr,
    required this.selectedDate,
    required this.magmo3aModel,
    required this.student,
    super.key,
  });

  @override
  State<Thestudentwhojustgetremoved> createState() =>
      _ThestudentwhojustgetremovedState();
}

class _ThestudentwhojustgetremovedState
    extends State<Thestudentwhojustgetremoved> {
  late Future<Studentmodel?> studentFuture;
  late bool isInGroup;

  @override
  void initState() {
    super.initState();
    isInGroup = widget.student?.firstDayId == widget.magmo3aModel.id ||
        widget.student?.secondDayId == widget.magmo3aModel.id ||
        widget.student?.thirdDayId == widget.magmo3aModel.id ||
        widget.student?.fourthDayId == widget.magmo3aModel.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Abssentpage(
                  selectedDay: widget.selectedDate,
                  selectedDateStr: widget.selectedDateStr,
                  magmo3aModel: widget.magmo3aModel,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          },
          icon: Icon(Icons.arrow_back_ios, color: app_colors.orange),
        ),
        backgroundColor: app_colors.green,
        title: Image.asset(
          "assets/images/2....2.png",
          height: 100,
          width: 90,
        ),
        toolbarHeight: 180,
      ),
      body: Expanded(
        child: ListView(
          children: [
            normalstudentwiget(
              studentModel: widget.student,
              grade: widget.magmo3aModel.grade,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.student?.firstDayId == widget.magmo3aModel.id ||
                          widget.student?.secondDayId ==
                              widget.magmo3aModel.id ||
                          widget.student?.thirdDayId ==
                              widget.magmo3aModel.id ||
                          widget.student?.fourthDayId == widget.magmo3aModel.id
                      ? "Yes, this student is in this group."
                      : "No, this student is not in this group.",
                  style: TextStyle(
                    color: isInGroup ? app_colors.green : Colors.red,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: app_colors.orange,
              thickness: 4,
            ),

            Column(
              children: [
                Text(
                  "Last time this student attended",
                  style: TextStyle(fontSize:18,color:app_colors.green),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          "Last date ",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.lastTimeDate??"He didn't attend before " ,
                          style: TextStyle(fontSize: 10,color: app_colors.orange),
                        ),
                      ],
                    ) ,
                    Column(
                      children: [
                        Text(
                          "Last day ",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.lastTimeDay??"He didn't attend before " ,
                          style: TextStyle(fontSize: 10,color: app_colors.orange),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: app_colors.orange,
              thickness: 4,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    showDateOfPaidMonth(
                        "First month", widget.student?.dateOfFirstMonthPaid),
                    showDateOfPaidMonth(
                        "Second month", widget.student?.dateOfSecondMonthPaid),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    showDateOfPaidMonth(
                        "Third month", widget.student?.dateOfThirdMonthPaid),
                    showDateOfPaidMonth(
                        "Fourth month", widget.student?.dateOfFourthMonthPaid),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    showDateOfPaidMonth(
                        "Fifth month", widget.student?.dateOfFifthMonthPaid),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: app_colors.orange,
              thickness: 4,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                showNumberOfAbsenceAndPresence(
                    "AttendantDays", widget.student?.numberOfAttendantDays),
                showNumberOfAbsenceAndPresence(
                    "AbsentDays", widget.student?.numberOfAbsentDays)
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget showDateOfPaidMonth(
    String label,
    String? date,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date ?? "he didn't pay for this yet",
              style: const TextStyle(fontSize: 10, color: app_colors.orange),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget showNumberOfAbsenceAndPresence(
    String label,
    int? number,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (number ?? 0).toString(),
              style: const TextStyle(fontSize: 16, color: app_colors.orange),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
