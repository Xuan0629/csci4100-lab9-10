import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracking App'),
      ),
      body: Center(
        child: Text('Map will be displayed here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality here in later steps
        },
        child: Icon(Icons.add_location),
        tooltip: 'Add Location',
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracking App'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {
              // Zoom in functionality will be added later
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            onPressed: () {
              // Zoom out functionality will be added later
            },
          ),
        ],
      ),
    );
  }
}
