import 'package:flutter/material.dart';
import '../../models/Magmo3amodel.dart';
import '../otherPages/AbssentPage.dart';
import '../colors_app.dart';

class Magmo3aWidget extends StatelessWidget {
  final Magmo3amodel magmo3aModel;
  final String selectedDateStr;
  final String selectedDay;

  const Magmo3aWidget({
    required this.magmo3aModel,
    required this.selectedDateStr,
    required this.selectedDay,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDaysList(),
                    const SizedBox(height: 10),
                    _buildGradeAndTime(),
                  ],
                ),
              ),
              _buildDetailsButton(context),
            ],
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
      height: 70,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                color: app_colors.green,
                border: Border.all(color: app_colors.orange, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                magmo3aModel.days ?? "",
                style: TextStyle(
                  fontSize: 30,
                  color: app_colors.ligthGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeAndTime() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "الصف: ",
                      style: TextStyle(fontSize: 17, color: app_colors.green),
                    ),
                    TextSpan(
                      text: "${magmo3aModel.grade ?? ''}",
                      style: TextStyle(fontSize: 20, color: app_colors.orange),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "الوقت: ",
                      style: TextStyle(fontSize: 17, color: app_colors.green),
                    ),
                    TextSpan(
                      text: magmo3aModel.time != null
                          ? _formatTime(magmo3aModel.time!)
                          : '',
                      style: TextStyle(fontSize: 20, color: app_colors.orange),
                    ),
                  ],
                ),
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
    return "$formattedHour:$formattedMinute ${isPm ? 'م' : 'ص'}";
  }

  Widget _buildDetailsButton(BuildContext context) {
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
              ),
            );
          },
          icon: Container(
            decoration: BoxDecoration(
              color: app_colors.green,
              border: Border.all(color: app_colors.orange, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_forward_ios, color: app_colors.orange),
          ),
        ),
      ],
    );
  }
}
