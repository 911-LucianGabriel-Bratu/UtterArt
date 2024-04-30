import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              child: const Text('Confirm'), // Replace with appropriate action
              onPressed: () {
                Navigator.of(context).pop();
                fetchImageAndShowDialog(context);
              },
            ),
          ],
        );
      },
    );
  }
  static Future<void> fetchImageAndShowDialog(BuildContext context) async {
    String? imageBytes = await Api.getImageFromBackend();
    if (imageBytes != null) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.memory(base64Decode(imageBytes)),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Show an error dialog if fetching image fails
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Failed to fetch image from backend.'),
          );
        },
      );
    }
  }
}