import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:utter_art/components/drawer.dart';
import 'package:utter_art/components/upload_file_button.dart';
import 'package:record/record.dart';
import 'package:utter_art/themes/theme.dart';

import 'components/dialogs.dart';
import 'database/database_helper.dart';
import 'components/check_connectivity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const materialTheme = MaterialTheme(TextTheme());
    final themeData = materialTheme.light();
    return MaterialApp(
      title: 'UtterArt',
      theme: themeData,
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
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _isConnected = false;
  String audioPath = '';
  late Record _audioRecord;
  late AudioPlayer _audioPlayer;
  PlayerState _audioPlayerState = PlayerState.stopped;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    _audioRecord = Record();

    CheckConnectivity.checkInternetConnectivity().then((isConnected) {
      if(mounted){
        setState(() {
          _isConnected = isConnected;
        });
      }
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(mounted){
        setState(() {
          _isConnected = (result == ConnectivityResult.mobile ||
              result == ConnectivityResult.wifi);
        });
        if(_isConnected){
          Fluttertoast.showToast(
            msg: "Established connection",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            textColor: Colors.black,
            fontSize: 16.0,
          );
        }
        else {
          Fluttertoast.showToast(
            msg: "Lost connection",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            textColor: Colors.black,
            fontSize: 16.0,
          );
        }
      }
    });
    super.initState();
  }

  @override
  void dispose(){
    _audioRecord.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    try{
      if(await _audioRecord.hasPermission()){
        await _audioRecord.start(encoder: AudioEncoder.wav);
      }
    }
    catch(e){
      print('Error Start Recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    try{
      String? path = await _audioRecord.stop();
      return path;
    }
    catch(e){
      print('Error Stop Recording: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: !_isConnected ? (){
              Fluttertoast.showToast(
                msg: "No internet connection",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                textColor: Colors.black,
                fontSize: 16.0,
              );
            } : () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, setState){
                        return AlertDialog(
                          title: const Text("Record Audio"),
                          content: const Text("Press the Start Recording button to record your voice."),
                          actions: [
                            TextButton(
                                onPressed: _isRecording ? null : () async {
                                  await startRecording();
                                  setState(() =>
                                  _isRecording = true
                                  );
                                },
                                child: const Text("Start Recording")
                            ),
                            TextButton(
                                onPressed: !_isRecording ? null : () async {
                                  String? path = await stopRecording();
                                  setState(() {
                                    _isRecording = false;
                                    _hasRecorded = true;
                                    if(path != null){
                                      audioPath = path;
                                    }
                                  });

                                },
                                child: const Text("Stop Recording")
                            ),
                            TextButton(
                                onPressed: !_hasRecorded ? null : () async {
                                  Dialogs.showAudioPreviewDialogForRecording(File(audioPath), context);
                                },
                                child: const Text("Preview")
                            ),
                            TextButton(
                              onPressed: () {
                                if(!_isRecording){
                                  audioPath = '';
                                  _hasRecorded = false;
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      }
                  );
                },
              );
            },
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child:_isUploading
            ? const CircularProgressIndicator() : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AudioUploadButton(
              onPressed: !_isConnected ? () {
                Fluttertoast.showToast(
                  msg: "No internet connection",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  textColor: Colors.black,
                  fontSize: 16.0,
                );
              } : () async {
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
                    if(!context.mounted) return;
                    Dialogs.showAudioPreviewDialog(file, context);
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
