import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:utter_art/components/drawer.dart';

class MyImagesPage extends StatefulWidget {

  final String title;
  const MyImagesPage({super.key, required this.title});

  @override
  _MyImagesPageState createState() => _MyImagesPageState();

}

class _MyImagesPageState extends State<MyImagesPage>{

  @override
  void initState(){
    super.initState();
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
        decoration: BoxDecoration(
            color: Colors.white
        ),
        child: ListView(),
      ),
    );
  }
}