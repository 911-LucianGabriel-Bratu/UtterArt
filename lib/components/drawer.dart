import 'package:flutter/material.dart';
import 'package:utter_art/main.dart';
import 'package:utter_art/pages/my_images_page.dart';

class AppDrawer extends StatefulWidget {

  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();

}

class _AppDrawerState extends State<AppDrawer>{

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background
        ),
        alignment: Alignment.center,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary
              ), child: null,
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.home, color: Colors.black),
                  SizedBox(width: 10),
                  Text('Home')
                ],
              ),
              onTap: () =>  {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage(title: "Home")
                    )
                )
              }
            ),
            ListTile(
              title: const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.black),
                  SizedBox(width: 10),
                  Text('My images')
                ],
              ),
              onTap: () =>  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyImagesPage(title: 'Images')
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}