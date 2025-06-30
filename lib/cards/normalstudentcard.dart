import 'package:flutter/material.dart';
import '../colors_app.dart';
import '../models/Studentmodel.dart';

class normalstudentwiget extends StatelessWidget {
  final Studentmodel? studentModel;
  final String? grade;

  normalstudentwiget({
    required this.studentModel,
    required this.grade,
    super.key,
  });

  final TextEditingController _noteController = TextEditingController();

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
              _buildInfoRow(context, "Name:", studentModel?.name ?? 'N/A'),
              _buildInfoRow(
                  context, "Phone Number:", studentModel?.phoneNumber ?? 'N/A'),
              _buildInfoRow(
                  context, "Mother Number:", studentModel?.motherPhone ?? 'N/A'),
              _buildInfoRow(
                  context, "Father Number:", studentModel?.fatherPhone ?? 'N/A'),
              _buildInfoRow(context, "Grade:", studentModel?.grade ?? 'N/A'),
              const SizedBox(height: 10),
              _buildStudentDaysList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: app_colors.green,
            fontSize: 18,
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: app_colors.green.withOpacity(0.5),
              cursorColor: app_colors.green,
            ),
          ),
          child: SelectableText(
            value,
            style: const TextStyle(
              color: app_colors.orange,
              fontSize: 25,
            ),
          ),
        ),
      ],
    );
  }

  // Widget to display student-specific days if available
  Widget _buildStudentDaysList() {
    // Assuming `studentModel.hisGroups` is a list of Magmo3amodel
    List<Map<String, dynamic>> daysWithTimes = studentModel?.hisGroups?.map((group) {
      return {
        'day': group.days, // Group days as a string (e.g., "Monday, Wednesday")
        'time': group.time != null
            ? {'hour': group.time?.hour, 'minute': group.time?.minute}
            : null,
      };
    }).toList() ?? [];

    // Remove entries where day is null
    daysWithTimes.removeWhere((entry) => entry['day'] == null);

    return Row(
      children: [
        const Text(
          "Student Days:",
          style: TextStyle(
            color: app_colors.green,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: daysWithTimes.map((entry) {
                String day = entry['day'] ?? '';
                TimeOfDay? time = entry['time'] != null
                    ? TimeOfDay(hour: entry['time']['hour'], minute: entry['time']['minute'])
                    : null;

                // Convert TimeOfDay to 12-hour format with AM/PM
                String timeString = time != null ? _formatTime12Hour(time) : 'No Time';

                return Row(
                  children: [
                    Chip(
                      label: Column(
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              color: app_colors.orange,
                            ),
                          ),
                          Text(
                            timeString,
                            style: const TextStyle(
                              color: app_colors.orange,
                              fontSize: 12, // Smaller font for time
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: app_colors.green,
                    ),
                    const SizedBox(width: 8),
                    // Add some space between each day
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
  String _formatTime12Hour(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod; // Convert 0 to 12 for midnight/noon
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final String minute =
    time.minute.toString().padLeft(2, '0'); // Ensure two digits for minutes
    return '$hour:$minute $period';
  }

}
