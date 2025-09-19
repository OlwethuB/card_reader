import 'package:card_reader/components/details_form.dart';
import 'package:card_reader/components/scan_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Card Details Reader"),
          // Left Side
          actions: <Widget>[
            //IconButton
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Setting Icon',
              onPressed: () {},
            ),
          ],
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 50.0,
          // Right Side
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,

          bottom: const TabBar(
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.email)),
              Tab(icon: Icon(Icons.camera_alt)),
            ],
          ), // TabBar
        ), // AppBar

        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Handle tap for Home
                  print('Home tapped');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Handle tap for Settings
                  print('Settings tapped');
                },
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text('About'),
                onTap: () {
                  // Handle tap for About
                  print('About tapped');
                },
              ),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            DetailsForm(), // The Details form
            ScanCamera(), // The Camera scan
          ],
        ), // TabBarView
      ), // Scaffold
    );
  }
}
