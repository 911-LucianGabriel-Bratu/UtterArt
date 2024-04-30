import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:utter_art/database/database_helper.dart';

import '../api/api.dart';

class Dialogs {
  static Future<void> showConfirmationDialog(String prediction, BuildContext context) async {
    TextEditingController controller = TextEditingController(text: prediction);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Does this transcription look correct?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Transcription text',
                  ),
                  controller: controller,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                String textFieldPredictionText = controller.text;
                fetchImageAndShowDialog(textFieldPredictionText, context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  static Future<void> fetchImageAndShowDialog(String prediction, BuildContext context) async {
    String? imageBytes = await Api.getImageFromBackend();
    if (imageBytes != null) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.memory(base64Decode(imageBytes)),
                TextButton(
                  onPressed: () async {
                    await saveImageAndInsertIntoDb(imageBytes, prediction);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Text('Failed to fetch image from backend.'),
          );
        },
      );
    }
  }
  static Future<void> showImageDialog(File? imageFile, BuildContext context) async {
    if (imageFile != null) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.file(imageFile),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Text('Failed to display image.'),
          );
        },
      );
    }
  }
}