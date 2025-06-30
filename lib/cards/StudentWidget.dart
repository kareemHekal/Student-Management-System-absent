import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../colors_app.dart';
import '../../models/Studentmodel.dart';
import '../Alertdialogs/Notify Absence.dart';
import '../firbase/FirebaseFunctions.dart';
import '../models/Magmo3amodel.dart';

class StudentWidget extends StatefulWidget {
  final Studentmodel studentModel;
  final String? grade;
  final String selectedDateStr; // Ensure this is a String
  final String selectedDate; // Ensure this is a String
  final Magmo3amodel magmo3aModel;

  StudentWidget({
    required this.magmo3aModel,
    required this.selectedDateStr,
    required this.selectedDate,
    required this.studentModel,
    required this.grade,
    super.key,
  });

  @override
  State<StudentWidget> createState() => _StudentWidgetState();
}

class _StudentWidgetState extends State<StudentWidget> {
  final TextEditingController _noteController = TextEditingController();
  String? noteForSelectedDate;

  void initState() {
    super.initState();
    _loadNotes();
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


  void _sendMessageToParent(String parentRole) {
    String genderSpecificMessage;

    // Determine the parent's role and customize the message
    if (parentRole == 'father') {
      genderSpecificMessage = """
عزيزي والد ${widget.studentModel.name} أو والدته ${widget.studentModel.name}،

ابنك ${widget.studentModel.name} غائب اليوم عن حصة مس فاطمة العرباني.

أطيب التحيات،
فاطمة العرباني
      """;
    } else if (parentRole == 'mother') {
      genderSpecificMessage = """
عزيزتي والدة ${widget.studentModel.name} أو والده ${widget.studentModel.name}،

ابنك ${widget.studentModel.name} غائب اليوم عن حصة مس فاطمة العرباني.

أطيب التحيات،
فاطمة العرباني
      """;
    } else {
      genderSpecificMessage = """
عزيزي ${widget.studentModel.name}،

أنت غائب اليوم عن حصة مس فاطمة العرباني.
      """;
    }

    // Send the message based on the parent's role
    if (parentRole == 'father') {
      _sendWhatsAppMessage(widget.studentModel.fatherPhone!, genderSpecificMessage);
    } else if (parentRole == 'mother') {
      _sendWhatsAppMessage(widget.studentModel.motherPhone!, genderSpecificMessage);
    } else {
      _sendWhatsAppMessage(widget.studentModel.phoneNumber!, genderSpecificMessage);
    }
  }
  Future<void> _sendWhatsAppMessage(String phoneNumber, String message) async {
    // Format the phone number
    final String formattedPhone = phoneNumber.startsWith('0')
        ? '+20${phoneNumber.substring(1)}'
        : phoneNumber;

    // Print the formatted phone number
    print("Formatted Phone Number: $formattedPhone");

    // Encode the message
    final String encodedMessage = Uri.encodeComponent(message);

    // Build the WhatsApp URL
    final Uri url = Uri.parse(
        'whatsapp://send?phone=$formattedPhone&text=$encodedMessage');

    // Print the WhatsApp URL for debugging
    print("WhatsApp URL: $url");

    try {
      // Check if WhatsApp can be launched
      bool canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print("WhatsApp is not installed or cannot be opened.");
      }
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  Future<void> _loadNotes() async {
    if (!mounted) return;
    setState(() {
      noteForSelectedDate = _getNoteForDate(widget.selectedDateStr);
    });
  }

  String _getNoteForDate(String dateKey) {
    if (widget.studentModel.notes == null ||
        widget.studentModel.notes!.isEmpty) {
      return "There are no notes";
    }

    for (var note in widget.studentModel.notes!) {
      if (note.containsKey(dateKey)) {
        return note[dateKey] ?? "";
      }
    }

    return "No notes for $dateKey";
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${widget.studentModel.dateofadd}",
                    style: TextStyle(color: app_colors.orange),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  _buildIconButton(
                    imagePath: "assets/icon/whatsapp.png",
                    // Path to WhatsApp icon
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: app_colors.ligthGreen,
                          title: Text(
                            'Who would you like to send the message to?',
                            style: TextStyle(color: app_colors.green),
                          ),
                          content: SelectRecipientDialogContent(
                            sendMessageToFather: () => _sendMessageToParent('father'),
                            sendMessageToMother: () => _sendMessageToParent('mother'),
                            sendMessageToStudent: () => _sendMessageToParent('student'),
                          ),
                          actions: [
                            Material(
                              color: Colors.transparent,
                              // Make the material background transparent
                              elevation: 10,
                              // Set elevation for the shadow effect
                              shadowColor: Colors.black.withOpacity(0.5),
                              // Set shadow color
                              borderRadius: BorderRadius.circular(10),
                              // Optional: Add rounded corners
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: app_colors.orange,
                                  // Set background color
                                  foregroundColor: Colors.white,
                                  // Set text color for contrast
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal:
                                          16), // Optional: Adjust padding
                                ),
                                child: const Text('Cancel'),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      _showAddNoteDialog(context);
                    },
                    icon: Icon(Icons.add),
                  ),
                  ElTooltip(
                      showArrow: true,
                      color: app_colors.ligthGreen,
                      position: ElTooltipPosition.leftEnd,
                      content: SizedBox(
                        height: 100,
                        width: 150,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // Keep content centered
                            children: [
                              // Absence Excuse Title
                              Align(
                                alignment: Alignment.centerLeft,
                                // Align title to the left
                                child: Text(
                                  "Absence Excuse",
                                  style: TextStyle(
                                    fontSize: 18, // Make the title bigger
                                    fontWeight:
                                        FontWeight.w700, // Make the title w700
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Add some space between the title and content

                              // Absence Excuse Content (centered)
                              Center(
                                child:
                                    _buildNotesForDate(widget.selectedDateStr),
                              ),

                              const Divider(
                                  color: app_colors.orange, thickness: 3),

                              // Regular Note Title
                              Align(
                                alignment: Alignment.centerLeft,
                                // Align title to the left
                                child: Text(
                                  "Regular Note",
                                  style: TextStyle(
                                    fontSize: 18, // Make the title bigger
                                    fontWeight:
                                        FontWeight.w700, // Make the title bold
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Add some space between the title and content

                              // Regular Note Content (centered)
                              Center(
                                child: Text(
                                  widget.studentModel.note ??
                                      "There is no note",
                                  textAlign: TextAlign
                                      .center, // Center the text content
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          "assets/images/comment.gif",
                          width: 50,
                          height: 50,
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoRow(
                  context, false, "Name:", widget.studentModel.name ?? 'N/A'),
              _buildInfoRow(context, true, "Phone Number:",
                  widget.studentModel.phoneNumber ?? 'N/A'),
              _buildInfoRow(context, true, "Mother Number:",
                  widget.studentModel.motherPhone ?? 'N/A'),
              _buildInfoRow(context, true, "Father Number:",
                  widget.studentModel.fatherPhone ?? 'N/A'),
              _buildInfoRow(
                  context, false, "Grade:", widget.studentModel.grade ?? 'N/A'),
              const SizedBox(height: 10),
              _buildStudentDaysList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, bool isnumber, String label, String value) {
    void _launchPhoneNumber(String phoneNumber) async {
      final String phoneUrl = 'tel:$phoneNumber';
      if (await canLaunchUrlString(phoneUrl)) {
        await launchUrlString(phoneUrl);
      } else {
        print('Could not launch $phoneNumber');
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
          const SizedBox(width: 20),
          Flexible(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: app_colors.green.withOpacity(0.5),
                  cursorColor: app_colors.green,
                ),
              ),
              child: GestureDetector(
                onLongPress: isnumber ? () => _launchPhoneNumber(value) : null,
                // Check isnumber
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: app_colors.orange,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Image.asset(
            imagePath,
            width: 30,
            height: 30,
          ),
        ), // مسافة بين الصورة والنص
      ],
    );
  }

  Widget _buildStudentDaysList() {
    // Assuming `studentModel.hisGroups` is a list of Magmo3amodel
    List<Map<String, dynamic>> daysWithTimes = widget.studentModel.hisGroups?.map((group) {
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
  // Method to build notes for the selected date
  Widget _buildNotesForDate(String dateKey) {
    if (widget.studentModel.notes == null ||
        widget.studentModel.notes!.isEmpty) {
      return Text("There are no notes");
    }

    // Find note for the selected date
    String? noteForSelectedDate;
    for (var note in widget.studentModel.notes!) {
      if (note.containsKey(dateKey)) {
        noteForSelectedDate = note[dateKey];
        break; // Stop once we find the note for the selected date
      }
    }

    // Display the note for the selected date
    if (noteForSelectedDate != null) {
      return Text(" $noteForSelectedDate");
    } else {
      return Text("No notes for $dateKey");
    }
  }

  void _showAddNoteDialog(BuildContext context) {
    String existingNote = "";

    if (widget.studentModel.notes != null) {
      for (var existing in widget.studentModel.notes!) {
        if (existing.containsKey(widget.selectedDateStr)) {
          existingNote = existing[widget.selectedDateStr] ??
              ""; // Get the existing note or set to empty
          break;
        }
      }
    }

    // Set the initial value of the TextEditingController to the existing note
    _noteController.text = existingNote;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: SingleChildScrollView(
            // إضافة SingleChildScrollView هنا
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  // استخدام TextField
                  style: TextStyle(color: Colors.green),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Add note',
                    hintStyle: TextStyle(color: Colors.green),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange, width: 2.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.orange),
                      onPressed: () {
                        _noteController.clear();
                      },
                    ),
                  ),
                  cursorColor: Colors.green,
                  controller: _noteController,
                  autofocus:
                      true, // إضافة autofocus لجعل الحقل يأخذ التركيز تلقائيًا
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String note = _noteController.text;
                String dateKey =
                    widget.selectedDateStr; // Use the selected date

                // Check if a note for the specific date already exists
                bool noteExists = false;
                if (widget.studentModel.notes != null) {
                  for (var existing in widget.studentModel.notes!) {
                    if (existing.containsKey(dateKey)) {
                      // Update the existing note
                      existing[dateKey] = note;
                      noteExists = true;
                      break;
                    }
                  }
                }

                // If the note does not exist, add a new entry
                if (!noteExists) {
                  widget.studentModel.notes?.add({dateKey: note});
                }

                // Call the Firebase function to update the student with the new notes
                Firebasefunctions.updateStudentInAbsence(
                  widget.selectedDate,
                  widget.magmo3aModel.id,
                  widget.selectedDateStr,
                  widget.studentModel.id,
                  widget.studentModel,
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
