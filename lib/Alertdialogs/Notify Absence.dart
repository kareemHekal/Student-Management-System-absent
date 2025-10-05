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
          title: Text('Father', style: TextStyle(color: app_colors.orange),),
          onTap: () {
            Navigator.of(context).pop();
            sendMessageToFather();
            print("father");
          },
        ),
        ListTile(
          title: Text('Mother',style: TextStyle(color: app_colors.orange),),
          onTap: () {
            Navigator.of(context).pop();
            sendMessageToMother();
            print("mother");

          },
        ),
        ListTile(
          title: Text('Student',style: TextStyle(color: app_colors.orange),),
          onTap: () {
            Navigator.of(context).pop();
            sendMessageToStudent();
            print("anaaaaaaaaaaaaa");
          },
        ),
      ],
    );
  }
}
