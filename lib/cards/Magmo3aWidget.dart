import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/Magmo3amodel.dart';
import '../otherPages/AbssentPage.dart';
import '../colors_app.dart';

class Magmo3aWidget extends StatelessWidget {
  final Magmo3amodel magmo3aModel;
  final String selectedDateStr;
  final String selectedDay;

  const Magmo3aWidget(
      {required this.magmo3aModel,
      required this.selectedDateStr,
      required this.selectedDay,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          color: app_colors.ligthGreen,
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _buildVerticalLine(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      _buildDaysList(),
                      const SizedBox(height: 10),
                      _buildGradeAndTimeAndType(),
                    ],
                  ),
                ),
                _buildDetailsButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        decoration: BoxDecoration(
          color: app_colors.orange,
          borderRadius: BorderRadius.circular(25),
        ),
        width: 5,
        height: 200,
      ),
    );
  }

  Widget _buildDaysList() {
    return SizedBox(
      height: 70, // increased height
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0), // increased padding
            child: Container(
              decoration: BoxDecoration(
                color: app_colors.green,
                border: Border.all(
                  color: app_colors.orange,
                  width: 2, // increased border width
                ),
                borderRadius: BorderRadius.circular(15), // increased radius
              ),
              padding: const EdgeInsets.all(8.0), // added padding
              child: Text(
                magmo3aModel.days ?? "", // Display the full day name
                style: TextStyle(
                  fontSize: 30, // increased font size
                  color: app_colors.orange,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGradeAndTimeAndType() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Grade: ",
                      style: TextStyle(
                        fontSize: 17,
                        color: app_colors.green,
                      ),
                    ),
                    TextSpan(
                      text: "${magmo3aModel.grade ?? ''}",
                      style: TextStyle(
                        fontSize: 20,
                        color: app_colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: " Time : ",
                      style: TextStyle(
                        fontSize: 17,
                        color: app_colors.green,
                      ),
                    ),
                    TextSpan(
                      text: magmo3aModel.time != null
                          ? "${_formatTime(magmo3aModel.time!)}"
                          : '',
                      style: TextStyle(
                        fontSize: 20,
                        color: app_colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final isPm = hour >= 12;

    final formattedHour = hour > 12 ? hour - 12 : hour;
    final formattedMinute = minute.toString().padLeft(2, '0');

    return "$formattedHour:$formattedMinute ${isPm ? 'PM' : 'AM'}";
  }

  Widget _buildDetailsButton(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AbsentPage(
                    selectedDateStr: selectedDateStr,
                    magmo3aModel: magmo3aModel,
                    selectedDay: selectedDay,
                  ),
                ));
          },
          icon: Container(
            decoration: BoxDecoration(
              color: app_colors.green,
              border: Border.all(
                color: app_colors.orange,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: app_colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
