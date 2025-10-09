import 'package:flutter/material.dart';

Future<void> showPhotoViewer(BuildContext context, String url) async {
  await showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: InteractiveViewer(
        child: Image.network(url, fit: BoxFit.contain),
      ),
    ),
  );
}
