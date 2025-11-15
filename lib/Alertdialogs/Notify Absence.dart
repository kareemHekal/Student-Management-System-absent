import 'package:flutter/material.dart';
import '../colors_app.dart';

class SelectRecipientDialogContent extends StatelessWidget {
  final VoidCallback sendMessageToMother;
  final VoidCallback sendMessageToStudent;
  final VoidCallback sendMessageToFather;
  const SelectRecipientDialogContent({
    Key? key,
    required this.sendMessageToFather,
    required this.sendMessageToMother,
    required this.sendMessageToStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('الأب', style: TextStyle(color: app_colors.orange)),
          onTap: () {
            Navigator.of(context).pop();
            sendMessageToFather();
            print("الأب");
          },
        ),
        ListTile(
          title: Text('الأم', style: TextStyle(color: app_colors.orange)),
          onTap: () {
            Navigator.of(context).pop();
            sendMessageToMother();
            print("الأم");
          },
        ),
        ListTile(
          title: Text('الطالب', style: TextStyle(color: app_colors.orange)),
          onTap: () {
            Navigator.of(context).pop();
            sendMessageToStudent();
            print("الطالب");
          },
        ),
      ],
    );
  }
}
