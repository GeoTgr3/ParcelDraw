import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './mongoHelpers/mongoHelpers.dart';
import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MongoHelpers.instance
      .connect(); // Connect to MongoDB before running the app

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    MongoHelpers.instance
        .disconnect(); // Disconnect from MongoDB when the app is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue[900],
      ),
      home: Register(),
    );
  }
}
