import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../cards/StudentWidget.dart';
import '../colors_app.dart';
import '../firbase/FirebaseFunctions.dart';
import '../models/Magmo3amodel.dart';
import '../models/Studentmodel.dart';
import '../models/absancemodel.dart';
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
  late List<Studentmodel> filteredStudents; // List to hold filtered students
  final TextEditingController _searchController =
      TextEditingController(); // Search controller

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
    filteredStudents =
        widget.absenceModel.attendStudents; // Initially show all students
  }

  // Method to filter the list based on search query
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
                  builder: (context) => Abssentpage(
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
            "assets/images/2....2.png",
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
            preferredSize: Size.fromHeight(130), // Adjust height as needed
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
                  // Search Bar
                  TextFormField(
                    style: TextStyle(color: app_colors.green),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search',
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
                          _filterStudents(''); // Clear filter
                        },
                      ),
                    ),
                    cursorColor: app_colors.green,
                    controller: _searchController,
                    onChanged: (value) {
                      _filterStudents(value); // Filter students based on input
                    },
                  ),
                  SizedBox(height: 10),
                  // Number of Students
                  Text(
                    'Attending Students: ${filteredStudents.length}',
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
              child: Center(child: Image.asset("assets/images/1......1.png")),
            ),
            filteredStudents.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No one attended', // Message when no students are present
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
                                    title: Text('Confirm get him back',
                                        style:
                                            TextStyle(color: Colors.blue[900])),
                                    content: Text(
                                        'Are you sure you want to get him back?',
                                        style:
                                            TextStyle(color: Colors.blue[800])),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel',
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
                                          child: Text('Remove',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () {
                                            setState(() {
                                              // Get the student being moved
                                              final student = widget
                                                  .absenceModel
                                                  .attendStudents[index];

                                              // Add the student to the absentStudents list
                                              widget.absenceModel.absentStudents
                                                  .add(student);

                                              // Remove the student from the attendStudents list
                                              widget.absenceModel.attendStudents
                                                  .removeWhere((s) =>
                                                      s.id == student.id);

                                              // Update the student's days counters
                                              student.numberOfAbsentDays =
                                                  (student.numberOfAbsentDays ??
                                                          0) +
                                                      1;
                                              student.numberOfAttendantDays =
                                                  ((student.numberOfAttendantDays ??
                                                              0) -
                                                          1)
                                                      .clamp(0, double.infinity)
                                                      .toInt();

                                              // Update the student in the Firestore collection
                                              Firebasefunctions
                                                  .updateStudentInCollection(
                                                widget.magmo3aModel.grade ?? "",
                                                // Grade of the student
                                                student.id, // ID of the student
                                                student, // Updated student model
                                              );

                                              // Create an updated AbsenceModel
                                              AbsenceModel absenceModel =
                                                  AbsenceModel(
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

                                              // Update the AbsenceModel in Firestore
                                              Firebasefunctions
                                                  .updateAbsenceByDateInSubcollection(
                                                widget.selectedDay,
                                                widget.magmo3aModel.id,
                                                widget.absenceModel.date,
                                                absenceModel,
                                              );
                                            });

                                            // Close the dialog
                                            Navigator.of(context).pop();
                                          }),
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
