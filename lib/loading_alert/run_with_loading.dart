import 'package:flutter/material.dart';

import 'loading_dialog.dart';

Future<void> runWithLoading(
  BuildContext context,
  Future<void> Function() task, {
  String? loadingText,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => LoadingDialog(text: loadingText),
  );

  try {
    await task();
  } catch (e) {
    if (Navigator.canPop(context)) Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("حدث خطأ"),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
    return;
  }

  if (Navigator.canPop(context)) Navigator.pop(context);
}
