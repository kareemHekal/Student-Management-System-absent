import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bottomShets/more Bottom Sheet In Absent Page.dart';
import '../cards/StudentWidget.dart';
import '../colors_app.dart';
import '../firbase/FirebaseFunctions.dart';
import '../homeScreen.dart';
import '../models/Magmo3amodel.dart';
import '../models/absence_model.dart';
import 'view_model/cubit.dart';
import 'view_model/intent.dart';
import 'view_model/states.dart';

class AbsentPage extends StatelessWidget {
  final Magmo3amodel magmo3aModel;
  final String selectedDateStr;
  final String selectedDay;

  const AbsentPage({
    Key? key,
    required this.magmo3aModel,
    required this.selectedDateStr,
    required this.selectedDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AbsentCubit(
          magmo3aModel: magmo3aModel,
          selectedDateStr: selectedDateStr,
          selectedDay: selectedDay)
        ..handleIntent(FetchAbsence()),
      child: BlocConsumer<AbsentCubit, AbsentState>(
        listener: (context, state) {
          if (state is AbsentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.error),
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<AbsentCubit>();
          final selectedDate = DateTime.parse(cubit.selectedDateStr);
          final today = DateTime.now();
          final tomorrow = today.add(const Duration(days: 1));

          if (state is AbsentLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: app_colors.orange),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Homescreen()),
                        (route) => false,
                  );
                },
              ),
              centerTitle: true,
              backgroundColor: app_colors.green,
              title: Image.asset(
                "assets/images/2....logo.png",
                height: 100,
                width: 90,
              ),
              toolbarHeight: 150,
              actions: [
                if (cubit.isAttendanceStarted == true &&
                    selectedDate.isBefore(tomorrow)) ...[
                  IconButton(
                    icon: Image.asset("assets/images/qr-code.png",
                        width: 40, height: 40),
                    onPressed: () {
                      cubit.handleIntent(ScanQrIntent(context: context));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_outlined,
                        color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return CustomBottomSheet(
                            absenceModel: AbsenceModel(
                              date: cubit.selectedDateStr,
                              numberOfStudents: cubit.numberofstudents,
                              absentStudents: cubit.studentsList,
                              attendStudents: cubit.attendStudents,
                            ),
                            selectedDay: cubit.selectedDay,
                            magmo3aModel: cubit.magmo3aModel,
                            filteredStudentsList: cubit.filteredStudentsList,
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
              bottom: cubit.isAttendanceStarted == true
                  ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: cubit.searchController,
                        onChanged: (val) {
                          cubit.handleIntent(SearchStudent(query: val));
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'بحث',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: app_colors.orange),
                            onPressed: () {
                              cubit.searchController.clear();
                              cubit.handleIntent(SearchStudent(query: ''));
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: app_colors.orange, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('المجموع: ${cubit.numberofstudents}',
                              style: const TextStyle(
                                  color: app_colors.orange)),
                          Text('الغياب: ${cubit.studentsList.length}',
                              style: const TextStyle(
                                  color: app_colors.orange)),
                          Text('الحضور: ${cubit.attendStudents.length}',
                              style: const TextStyle(
                                  color: app_colors.orange)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : null,
            ),
            body: state == AbsentLoading()
                ? const Center(child: CircularProgressIndicator())
                : selectedDate.isAfter(tomorrow)
                ? const Center(
              child: Text(
                "لا يمكنك تسجيل حضور لتواريخ مستقبلية بعد الغد.",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
                : Column(
              children: [
                if (cubit.isAttendanceStarted != true &&
                    cubit.attendStudents.isEmpty &&
                    selectedDate.isBefore(tomorrow))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            cubit.numberofstudents =
                                cubit.studentsList.length;
                            await Firebasefunctions
                                .addAbsenceToSubcollection(
                              cubit.selectedDay,
                              cubit.magmo3aModel.id,
                              AbsenceModel(
                                date: cubit.selectedDateStr,
                                numberOfStudents:
                                cubit.numberofstudents,
                                absentStudents: cubit.studentsList,
                                attendStudents:
                                cubit.attendStudents,
                              ),
                            );
                            cubit.handleIntent(StartTakingAttendance());
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: app_colors.orange),
                          child: const Text(
                            "ابدأ تسجيل الغياب",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (cubit.isAttendanceStarted == true)
                  Expanded(
                    child: ListView.builder(
                      itemCount: cubit.filteredStudentsList.length,
                      itemBuilder: (context, index) {
                        final student =
                        cubit.filteredStudentsList[index];
                        return GestureDetector(
                          onLongPress: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'تأكيد الحذف',
                                    style: TextStyle(
                                        color: Colors.green[900]),
                                  ),
                                  content: Text(
                                    'هل تريد حذف هذا الطالب من الغياب؟',
                                    style: TextStyle(
                                        color: Colors.green[800]),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'إلغاء',
                                        style: TextStyle(
                                            color: Colors.green[400]),
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text(
                                        'حذف',
                                        style: TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                  backgroundColor: Colors.green[50],
                                );
                              },
                            );

                            if (confirm == true) {
                              await cubit.handleIntent(
                                AddStudentToPresent(
                                  context: context,
                                  student: student,
                                  realStudentId: student.id,
                                ),
                              );
                            }
                          },
                          child: StudentWidget(
                            selectedDate: cubit.selectedDay,
                            selectedDateStr: cubit.selectedDateStr,
                            magmo3aModel: cubit.magmo3aModel,
                            studentModel: student,
                            grade: cubit.magmo3aModel.grade,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
