import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:utter_art/components/drawer.dart';
import 'package:utter_art/components/upload_file_button.dart';

import 'api/api.dart';
import 'components/dialogs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UtterArt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child:_isUploading
            ? const CircularProgressIndicator() : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AudioUploadButton(
              onPressed: () async {
                try {
                  setState(() {
                    _isUploading = true;
                  });
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.audio,
                    allowMultiple: false,
                  );
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    print('File picked: ${file.name}');
                    String? prediction = await Api.uploadFile(File(file.path!));
                    if(prediction != null){
                      Dialogs.showConfirmationDialog(prediction, context);
                    }
                  } else {
                    print('File picking canceled');
                  }
                } catch (e) {
                  print('Error picking file: $e');
                }
                finally {
                  setState(() {
                    _isUploading = false;
                  });
                }
              },
            ),
          ],
        ),
      )
    );
  }
}
