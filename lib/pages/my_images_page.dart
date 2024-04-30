import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:utter_art/components/dialogs.dart';
import 'package:utter_art/components/drawer.dart';

import '../database/database_helper.dart';

class MyImagesPage extends StatefulWidget {

  final String title;
  const MyImagesPage({super.key, required this.title});

  @override
  _MyImagesPageState createState() => _MyImagesPageState();

}

class _MyImagesPageState extends State<MyImagesPage> {
  late List<Map<String, dynamic>> _images;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImagesFromDatabase();
  }

  Future<void> _loadImagesFromDatabase() async {
    List<Map<String, dynamic>> images = await DatabaseHelper().getImages();
    setState(() {
      _images = images;
      _loading = false;
    });
  }

  Future<File?> _getImageFile(String imageName) async {
    Directory? downloadsDirectory = await getExternalStorageDirectory();
    if (downloadsDirectory != null) {
      String imagePath = '${downloadsDirectory.path}/$imageName';
      File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: _loading
            ? const Center(child:CircularProgressIndicator()) :ListView.builder(
            itemCount: _images.length,
            itemBuilder: (context, index) {
              String imageName = _images[index]['image_name'];
              String predictionText = _images[index]['prediction_text'];
              return FutureBuilder<File?>(
                future: _getImageFile(imageName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    File? imageFile = snapshot.data;
                    if (imageFile != null) {
                      return ListTile(
                        leading: Image.file(imageFile),
                        title: Text(predictionText),
                        onTap: (){
                          Dialogs.showImageDialog(imageFile, context);
                        },
                      );
                    } else {
                      return ListTile(
                        title: Text(predictionText),
                        leading: const Icon(Icons.error),
                      );
                    }
                  }
                },
              );
            },
        ),
      ),
    );
  }
}