import 'package:flutter/material.dart';
import '../../colors_app.dart';
import '../../models/Studentmodel.dart';
import '../models/Magmo3amodel.dart';

class SmallStudentCard extends StatelessWidget {
  final Studentmodel studentModel;
  final String? grade;
  final String selectedDateStr; // Ensure this is a String
  final String selectedDate; // Ensure this is a String
  final Magmo3amodel magmo3aModel;

  SmallStudentCard({
    required this.magmo3aModel,
    required this.selectedDateStr,
    required this.selectedDate,
    required this.studentModel,
    required this.grade,
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: app_colors.ligthGreen,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, "Name:", studentModel.name ?? 'N/A'),
              SizedBox(height: 10,),
              _buildInfoRow(
                  context, "Phone Number:", studentModel.phoneNumber ?? 'N/A'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding if needed
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: app_colors.green,
              fontSize: 18,
            ),
          ),
          SizedBox(width: 20), // Add some space between the label and value
          Flexible(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: app_colors.green.withOpacity(0.5),
                  cursorColor: app_colors.green,
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  value,
                  style: const TextStyle(
                    color: app_colors.orange,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
