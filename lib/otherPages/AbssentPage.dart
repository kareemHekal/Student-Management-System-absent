import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fatma_elorbany_absent/otherPages/the%20student%20who%20just%20get%20removed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../bottomShets/more Bottom Sheet In Absent Page.dart';
import '../cards/StudentWidget.dart';
import '../colors_app.dart';

import '../firbase/FirebaseFunctions.dart';
import '../homeScreen.dart';
import '../models/Magmo3amodel.dart';
import '../models/Studentmodel.dart';
import '../models/absancemodel.dart';

class Abssentpage extends StatefulWidget {
  final String selectedDateStr;
  final String selectedDay;
  final Magmo3amodel magmo3aModel;

  Abssentpage(
      {required this.selectedDateStr,
      required this.magmo3aModel,
      required this.selectedDay,
      super.key});

  @override
  State<Abssentpage> createState() => _AbssentpageState();
}

class _AbssentpageState extends State<Abssentpage>
    with AutomaticKeepAliveClientMixin<Abssentpage> {
  final _searchController = TextEditingController();
  List<Studentmodel> studentsList = [];
  List<Studentmodel> attendStudents = [];
  bool isAttendanceStarted = false;
  List<Studentmodel> filteredStudentsList = [];
  final _controller = ValueNotifier<bool>(false);
  int? numberofstudents;
  bool isLoading = true;
  late bool isStudentInList;
  late String? lastTimeDate;
  late String? lastTimeDay;

  // Store the filtered list of students
  // New flag for loading state

//functions================================================================================================================================

  Future<void> _fetchAbsenceRecord() async {
    setState(() {
      isLoading = true; // بدء التحميل
    });
    try {
      AbsenceModel? absentStudents = await Firebasefunctions.getAbsenceByDate(
          widget.selectedDay, widget.magmo3aModel.id, widget.selectedDateStr);
      if (mounted) {
        // هنا
        if (absentStudents != null) {
          setState(() {
            attendStudents = absentStudents.attendStudents;
            numberofstudents = absentStudents.numberOfStudents;
            studentsList = absentStudents.absentStudents;
            attendStudents = absentStudents.attendStudents;
            filteredStudentsList = studentsList;
            isAttendanceStarted = true;
            isLoading = false;
          });
        } else {
          await _fetchStudentsList(); // تأكد من استخدام await هنا
        }
      }
    } catch (e) {
      if (mounted) {
        // هنا
        setState(() {
          isLoading = false; // إنهاء التحميل
        });
      }
      print("Error fetching absence record: $e");
    }
  }

  Future<void> _fetchStudentsList() async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });
      Stream<QuerySnapshot<Studentmodel>>? snapshotStream;
      if (widget.magmo3aModel.days == "Saturday" ||
          widget.magmo3aModel.days == "Sunday") {
        snapshotStream = Firebasefunctions.getStudentsByFirstDayId(
            widget.magmo3aModel.grade ?? "", widget.magmo3aModel.id);
      } else if (widget.magmo3aModel.days == "Monday" ||
          widget.magmo3aModel.days == "Tuesday") {
        snapshotStream = Firebasefunctions.getStudentsBySecondDayId(
            widget.magmo3aModel.grade ?? "", widget.magmo3aModel.id);
      } else if (widget.magmo3aModel.days == "Wednesday" ||
          widget.magmo3aModel.days == "Thursday") {
        snapshotStream = Firebasefunctions.getStudentsByThirdDayId(
            widget.magmo3aModel.grade ?? "", widget.magmo3aModel.id);
      } else if (widget.magmo3aModel.days == "Friday") {
        snapshotStream = Firebasefunctions.getStudentsByForthDayId(
            widget.magmo3aModel.grade ?? "", widget.magmo3aModel.id);
      }

      snapshotStream?.listen((snapshot) {
        if (mounted) {
          setState(() {
            studentsList = snapshot.docs.map((doc) => doc.data()).toList();
            filteredStudentsList = studentsList;
          });
        }
      });
    } catch (e) {
      print("Error fetching students: $e");
    } finally {
      setState(() {
        isLoading = false; // Data fetched, stop loading
      });
    }
  }

  Future<void> addStudentToList(grade, student) async {
    // Fetch student data from Firestore

    if (student != null) {
      // Check if the student is already in the attendance list
      isStudentInList = attendStudents.any((s) => s.id == student.id);

      if (isStudentInList) {
        // Show a Snackbar indicating the student is already in the attendance list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('This student is already in the attendance list.'),
            duration:
                Duration(seconds: 2), // You can adjust the duration as needed
          ),
        );
      } else {
        // Add the student to the list if they are not already in the attendance list
        setState(() {
          attendStudents.add(student); // Add student to the list
        });

        // Update the AbsenceModel with the new list of students
        AbsenceModel absenceModel = AbsenceModel(
          attendStudents: attendStudents,
          date: widget.selectedDateStr,
          numberOfStudents: numberofstudents,
          absentStudents: studentsList,
        );

        // Update the Firebase record for the attendance
        Firebasefunctions.updateAbsenceByDateInSubcollection(
          widget.selectedDay,
          widget.magmo3aModel.id,
          widget.selectedDateStr,
          absenceModel,
        );
      }
    }
  }

  void _startTakingAbsence() async {
    setState(() {
      isAttendanceStarted = true;
    });

    // Increment `numberOfAbsentDays` for each student and update in the database
    for (var student in studentsList) {
      // Ensure `numberOfAbsentDays` is not null and increment it
      student.numberOfAbsentDays = (student.numberOfAbsentDays ?? 0) + 1;

      // Update the student in the Firestore collection
      await Firebasefunctions.updateStudentInCollection(
        student.grade ?? "", // Assuming `grade` is a field in Studentmodel
        student.id, // Assuming `id` is a unique identifier in Studentmodel
        student,
      );
    }

    print("Attendance started: $isAttendanceStarted");
  }

  Future<void> updateStudentAttendanceAndAbsence(
      String grade, String studentId, Studentmodel student) async {

    student.numberOfAttendantDays = (student.numberOfAttendantDays ?? 0) + 1;
    student.numberOfAbsentDays = ((student.numberOfAbsentDays ?? 0) - 1)
        .clamp(0, double.infinity)
        .toInt();


// Save the old values of lastDayStudentCame and lastDateStudentCame
     lastTimeDay = student.lastDayStudentCame;
     lastTimeDate = student.lastDateStudentCame;

// Update the student's last day and date to the current date and day
    student.lastDayStudentCame = widget.selectedDay;
    student.lastDateStudentCame = widget.selectedDateStr;

// Now, update the student in Firestore
    await Firebasefunctions.updateStudentInCollection(
      grade, // Grade of the student
      studentId, // ID of the student
      student, // Updated student model
    );
  }

  Future<void> scanQrcode() async {
    // Navigate to the QR code scanner page
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AiBarcodeScanner(
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
              // Get the student from Firebase
              Studentmodel? student = await Firebasefunctions.getStudentById(
                  widget.magmo3aModel.grade ?? "", scannedValue);

              if (student != null) {
                // Add student to the list
                await addStudentToList(
                    widget.magmo3aModel.grade ?? "", student);
                setState(() {
                  // Remove the student from the students list
                  studentsList
                      .removeWhere((student) => student.id == scannedValue);

                  // Update AbsenceModel
                  AbsenceModel absenceModel = AbsenceModel(
                    attendStudents: attendStudents,
                    numberOfStudents: numberofstudents,
                    date: widget.selectedDateStr,
                    absentStudents: studentsList,
                  );

                  // Update Absence by date
                  Firebasefunctions.updateAbsenceByDateInSubcollection(
                    widget.selectedDay,
                    widget.magmo3aModel.id,
                    widget.selectedDateStr,
                    absenceModel,
                  );
                });
                // Update the student's attendance and absence
                updateStudentAttendanceAndAbsence(
                  widget.magmo3aModel.grade ?? "",// Pass grade
                  scannedValue, // Pass student ID
                  student, // Pass student model
                );
                // Navigate to the student removal page
                isStudentInList
                    ? null
                    : Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Thestudentwhojustgetremoved(
                            lastTimeDate: lastTimeDate,
                            lastTimeDay: lastTimeDay,
                            selectedDate: widget.selectedDay,
                            selectedDateStr: widget.selectedDateStr,
                            magmo3aModel: widget.magmo3aModel,
                            student: student,
                          ),
                        ),
                        (route) => false,
                      );
              } else {
                // Show error message using ScaffoldMessenger
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("Student not found!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

//functions================================================================================================================================

  @override
  void initState() {
    super.initState();
    if (_isValidDate()) {
      _fetchAbsenceRecord();
    } else {
      isLoading = false;
    }
    ;
  }

  _filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStudentsList = studentsList; // Reset to full list
      });
    } else {
      setState(() {
        filteredStudentsList = studentsList.where((student) {
          final studentName = student.name?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return studentName.contains(searchLower);
        }).toList();
      });
    }
  }

  @override
  void didUpdateWidget(Abssentpage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Use addPostFrameCallback to ensure the widget is built before calling this
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is mounted before fetching records
      if (mounted && _isValidDate()) {
        _fetchAbsenceRecord();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _isValidDate() {
    DateTime selectedDate = DateTime.parse(widget.selectedDateStr);
    DateTime todayDate = DateTime.now();
    DateTime tomorrowDate = todayDate.add(Duration(days: 1));
    return selectedDate.isBefore(tomorrowDate) ||
        selectedDate.isAtSameMomentAs(tomorrowDate);
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.parse(widget.selectedDateStr);
    DateTime todayDate = DateTime.now();
    super.build(context);
    DateTime tomorrowDate =
        todayDate.add(Duration(days: 1)); // Calculate tomorrow's date

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
              MaterialPageRoute(builder: (context) => Homescreen()),
              (route) => false,
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
        toolbarHeight: 150,
        actions: [
          if (isAttendanceStarted && selectedDate.isBefore(tomorrowDate)) ...[
            // QR Code Button
            IconButton(
              icon: Image.asset(
                "assets/images/qr-code.png",
                width: 40,
                height: 40,
              ),
              onPressed: () {
                scanQrcode();
              },
            ),

            // PDF Generation Button
            IconButton(
              icon: const Icon(Icons.more_vert_outlined, color: Colors.white),
              onPressed: () async {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (BuildContext context) {
                    return CustomBottomSheet(
                      absenceModel: AbsenceModel(
                          date: widget.selectedDateStr,
                          numberOfStudents: numberofstudents,
                          absentStudents: studentsList,
                          attendStudents: attendStudents),
                      selectedDay: widget.selectedDay,
                      magmo3aModel: widget.magmo3aModel,
                      filteredStudentsList: filteredStudentsList,
                    ); // استخدام الـ Bottom Sheet من الملف الجديد
                  },
                );
              },
            ),
          ],
        ],
        bottom: isAttendanceStarted
            ? PreferredSize(
                preferredSize:
                    Size.fromHeight(80), // Adjust the height as needed
                child: Container(
                  decoration: BoxDecoration(
                    color: app_colors.green,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Center the column items
                    children: [
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: TextFormField(
                            style: TextStyle(color: app_colors.green),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search',
                              hintStyle: TextStyle(color: app_colors.green),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: app_colors.orange, width: 2.0),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: app_colors.orange, width: 2.0),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              suffixIcon: IconButton(
                                icon:
                                    Icon(Icons.clear, color: app_colors.orange),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterStudents(''); // Clear filter
                                },
                              ),
                            ),
                            cursorColor: app_colors.green,
                            controller: _searchController,
                            onChanged: (value) {
                              _filterStudents(
                                  value); // Filter students based on input
                            },
                          )),
                      // Add your columns here for student attendance details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Total Students:  $numberofstudents',
                                      style:
                                          TextStyle(color: app_colors.orange)),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Absent Students:  ${studentsList.length}',
                                      style:
                                          TextStyle(color: app_colors.orange)),

                                  // Add a SizedBox here for spacing
                                  SizedBox(
                                      width: 30), // Adjust the width as needed

                                  Text(
                                      'Present Students:  ${numberofstudents! - studentsList.length} ',
                                      style:
                                          TextStyle(color: app_colors.orange)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Center(child: Image.asset("assets/images/1......1.png")),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  if (isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(app_colors.green),
                      ),
                    )
                  else if (selectedDate.isAfter(tomorrowDate))
                    Text(
                      "You can't take attendance for future dates beyond tomorrow.",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    )
                  else if (isAttendanceStarted)
                    Text("These are the students who are absent")
                  else if (!isAttendanceStarted &&
                      selectedDate.isBefore(tomorrowDate))
                    ElevatedButton(
                      onPressed: () async {
                        numberofstudents = studentsList.length;

                        ///put here the function to add 1 to the number of absent days for all the current students
                        AbsenceModel absence = AbsenceModel(
                          attendStudents: attendStudents,
                          numberOfStudents: numberofstudents,
                          date: widget.selectedDateStr,
                          absentStudents: studentsList,
                        );
                        await Firebasefunctions.addAbsenceToSubcollection(
                          widget.selectedDay,
                          widget.magmo3aModel.id,
                          absence,
                        );
                        _startTakingAbsence();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: app_colors.orange,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Start Taking Absence',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  if (isAttendanceStarted) ...[
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: filteredStudentsList.length,
                        cacheExtent: 1000.0,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Removal',
                                          style: TextStyle(
                                              color: Colors.green[900])),
                                      content: Text(
                                          'Are you sure you want to remove this student?',
                                          style: TextStyle(
                                              color: Colors.green[800])),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel',
                                              style: TextStyle(
                                                  color: Colors.green[400])),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: Text('Remove',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          onPressed: () async {
                                            // Perform asynchronous tasks outside of setState()
                                            final student = studentsList[index];

                                            // Update student's attendance and absence days
                                            await updateStudentAttendanceAndAbsence(
                                              widget.magmo3aModel.grade ?? "",
                                              // Pass grade
                                              student.id, // Pass student ID
                                              student, // Pass student model
                                            );

                                            // Add the student to the appropriate list
                                            addStudentToList(
                                              widget.magmo3aModel.grade,
                                              student,
                                            );
                                            studentsList.removeWhere(
                                                (student) =>
                                                    student.id ==
                                                    studentsList[index].id);

                                            // Create the updated AbsenceModel
                                            AbsenceModel absenceModel =
                                                AbsenceModel(
                                              attendStudents: attendStudents,
                                              date: widget.selectedDateStr,
                                              numberOfStudents:
                                                  numberofstudents,
                                              absentStudents: studentsList,
                                            );

                                            // Update the AbsenceModel in Firestore
                                            await Firebasefunctions
                                                .updateAbsenceByDateInSubcollection(
                                              widget.selectedDay,
                                              widget.magmo3aModel.id,
                                              widget.selectedDateStr,
                                              absenceModel,
                                            );

                                            // Now that async operations are done, update the state
                                            setState(() {
                                              // You can put any UI update here if needed
                                            });

                                            // Pop the current screen after the updates
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                      backgroundColor: Colors.green[50],
                                    );
                                  },
                                );
                              },
                              child: StudentWidget(
                                selectedDate: widget.selectedDay,
                                selectedDateStr: widget.selectedDateStr,
                                magmo3aModel: widget.magmo3aModel,
                                studentModel: filteredStudentsList[index],
                                // Use the filtered list
                                grade: widget.magmo3aModel.grade,
                              ));
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
