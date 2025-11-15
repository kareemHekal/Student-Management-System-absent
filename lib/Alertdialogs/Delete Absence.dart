import 'package:flutter/material.dart';
import '../colors_app.dart';
import '../homeScreen.dart';

class DeleteConfirmationDialogContent extends StatefulWidget {
  final VoidCallback onConfirm;

  const DeleteConfirmationDialogContent({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<DeleteConfirmationDialogContent> createState() =>
      _DeleteConfirmationDialogContentState();
}

class _DeleteConfirmationDialogContentState
    extends State<DeleteConfirmationDialogContent> {
  bool isProcessing = false;

  void _handleDelete() {
    setState(() {
      isProcessing = true;
    });

    widget.onConfirm();

    setState(() {
      isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "تم حذف الغياب بنجاح!",
            style: TextStyle(color: app_colors.white),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: app_colors.green), // Default text color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: app_colors.orange),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: app_colors.orange,
            foregroundColor: app_colors.ligthGreen,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "هل أنت متأكد من حذف هذا الغياب؟",
            style: TextStyle(color: app_colors.green),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text("إلغاء"),
              ),
              ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () {
                  _handleDelete();
                },
                child: isProcessing
                    ? const CircularProgressIndicator()
                    : const Text("حذف"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
