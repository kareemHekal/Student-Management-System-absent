import 'package:el_tooltip/el_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../colors_app.dart';
import '../../models/Studentmodel.dart';
import '../Alertdialogs/Notify Absence.dart';
import '../constants.dart';
import '../firbase/FirebaseFunctions.dart';
import '../models/Magmo3amodel.dart';

class StudentWidget extends StatefulWidget {
  final Studentmodel studentModel;
  final String? grade;
  final String selectedDateStr;
  final String selectedDate;
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

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  String _formatTime12Hour(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final String period = time.period == DayPeriod.am ? 'ص' : 'م';
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _sendMessageToParent(String parentRole) {
    String message;

    if (parentRole == 'father') {
      message = """
عزيزي والد الطالب ${widget.studentModel.name}،

نود إعلامكم بأن ابنكم ${widget.studentModel.name} غائب اليوم عن حصة الأستاذة ${Constants.teacherName}.

مع خالص التحية،
${Constants.teacherName}
    """;
    } else if (parentRole == 'mother') {
      message = """
عزيزتي والدة الطالب ${widget.studentModel.name}،

نود إعلامكم بأن ابنكم ${widget.studentModel.name} غائب اليوم عن حصة الأستاذة ${Constants.teacherName}.

مع خالص التحية،
${Constants.teacherName}
    """;
    } else {
      message = """
الطالب ${widget.studentModel.name}،

لقد تغيبت اليوم عن حصة الأستاذة ${Constants.teacherName}.
يرجى مراجعة الدروس الفائتة والالتزام بالحضور في المرات القادمة.

مع التحية،
${Constants.teacherName}
    """;
    }

    if (parentRole == 'father') {
      _sendWhatsAppMessage(widget.studentModel.fatherPhone!, message);
    } else if (parentRole == 'mother') {
      _sendWhatsAppMessage(widget.studentModel.motherPhone!, message);
    } else {
      _sendWhatsAppMessage(widget.studentModel.phoneNumber!, message);
    }
  }

  Future<void> _sendWhatsAppMessage(String rawPhone, String message) async {
    final cleanedPhone = rawPhone.replaceAll('+', '').replaceAll(' ', '');
    final String formattedPhone = cleanedPhone.startsWith('0')
        ? '20${cleanedPhone.substring(1)}'
        : cleanedPhone;
    final String encodedMessage = Uri.encodeComponent(message);
    final String url = 'https://wa.me/$formattedPhone?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("لا يمكن فتح WhatsApp أو غير مثبت.");
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
      return "لا توجد ملاحظات";
    }
    for (var note in widget.studentModel.notes!) {
      if (note.containsKey(dateKey)) {
        return note[dateKey] ?? "";
      }
    }
    return "لا توجد ملاحظات لهذا التاريخ";
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
                  SizedBox(width: 10),
                  _buildIconButton(
                    imagePath: "assets/icon/whatsapp.png",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: app_colors.ligthGreen,
                          title: Text(
                            'لمن تريد إرسال الرسالة؟',
                            style: TextStyle(color: app_colors.green),
                          ),
                          content: SelectRecipientDialogContent(
                            sendMessageToFather: () =>
                                _sendMessageToParent('father'),
                            sendMessageToMother: () =>
                                _sendMessageToParent('mother'),
                            sendMessageToStudent: () =>
                                _sendMessageToParent('student'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('إلغاء'),
                            ),
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
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "عذر الغياب",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child:
                                _buildNotesForDate(widget.selectedDateStr),
                              ),
                              const Divider(
                                  color: app_colors.orange, thickness: 3),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "ملاحظة عادية",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  widget.studentModel.note ??
                                      "لا توجد ملاحظة",
                                  textAlign: TextAlign.center,
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
              _buildInfoRow(context, false, "الاسم:", widget.studentModel.name ?? 'N/A'),
              _buildInfoRow(context, true, "رقم الهاتف:", widget.studentModel.phoneNumber ?? 'N/A'),
              _buildInfoRow(context, true, "رقم الأم:", widget.studentModel.motherPhone ?? 'N/A'),
              _buildInfoRow(context, true, "رقم الأب:", widget.studentModel.fatherPhone ?? 'N/A'),
              _buildInfoRow(context, false, "الصف:", widget.studentModel.grade ?? 'N/A'),
              const SizedBox(height: 10),
              _buildStudentDaysList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, bool isnumber, String label, String value) {
    void _launchPhoneNumber(String phoneNumber) async {
      final String phoneUrl = 'tel:$phoneNumber';
      if (await canLaunchUrlString(phoneUrl)) {
        await launchUrlString(phoneUrl);
      } else {
        print('لا يمكن الاتصال بهذا الرقم: $phoneNumber');
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
            child: GestureDetector(
              onLongPress: isnumber ? () => _launchPhoneNumber(value) : null,
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
        ),
      ],
    );
  }

  Widget _buildStudentDaysList() {
    List<Map<String, dynamic>> daysWithTimes = widget.studentModel.hisGroups?.map((group) {
      return {
        'day': group.days,
        'time': group.time != null
            ? {'hour': group.time?.hour, 'minute': group.time?.minute}
            : null,
      };
    }).toList() ?? [];

    daysWithTimes.removeWhere((entry) => entry['day'] == null);

    return Row(
      children: [
        const Text(
          "أيام الطالب:",
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
                String timeString = time != null ? _formatTime12Hour(time) : 'لا يوجد وقت';
                return Row(
                  children: [
                    Chip(
                      label: Column(
                        children: [
                          Text(day, style: const TextStyle(color: app_colors.orange)),
                          Text(timeString, style: const TextStyle(color: app_colors.orange, fontSize: 12)),
                        ],
                      ),
                      backgroundColor: app_colors.green,
                    ),
                    const SizedBox(width: 8),
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
          existingNote = existing[widget.selectedDateStr] ?? "";
          break;
        }
      }
    }
    _noteController.text = existingNote;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إضافة ملاحظة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: TextStyle(color: Colors.green),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'أضف ملاحظة',
                    hintStyle: TextStyle(color: Colors.green),
                    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
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
                      onPressed: () => _noteController.clear(),
                    ),
                  ),
                  cursorColor: Colors.green,
                  controller: _noteController,
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                String note = _noteController.text;
                String dateKey = widget.selectedDateStr;
                bool noteExists = false;
                if (widget.studentModel.notes != null) {
                  for (var existing in widget.studentModel.notes!) {
                    if (existing.containsKey(dateKey)) {
                      existing[dateKey] = note;
                      noteExists = true;
                      break;
                    }
                  }
                }
                if (!noteExists) {
                  widget.studentModel.notes?.add({dateKey: note});
                }
                Firebasefunctions.updateStudentInAbsence(
                  widget.selectedDate,
                  widget.magmo3aModel.id,
                  widget.selectedDateStr,
                  widget.studentModel.id,
                  widget.studentModel,
                );
                Navigator.of(context).pop();
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
