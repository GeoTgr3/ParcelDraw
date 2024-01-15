import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

import './ConstructionForm.dart';
import 'login.dart';
import 'models/localisation.dart';
import 'mongoHelpers/mongoHelpers.dart';

class Superviseur extends StatefulWidget {
  const Superviseur({super.key});

  @override
  State<Superviseur> createState() => _SuperviseurState();
}

class _SuperviseurState extends State<Superviseur> {
  String _lat = '';
  String _lng = '';
  //elate MongoHelpers mongoHelpers;
  List<Localization> myLocalisations = [];
  List<Map<String, dynamic>> myConstructions = [];
  late WebViewPlusController _controller;

  void fetch() async {
    print('fetchConstructions called'); // Add this line
    try {
      myLocalisations = await MongoHelpers.instance.readAll();
      myConstructions = await MongoHelpers.instance.readAllConstructions();

      print('myLocalisations: $myLocalisations');

      print('myConstructions: $myConstructions');

      if (myLocalisations.isEmpty) {
        print('No localisation fetched');
        return;
      }

      if (myLocalisations.isEmpty) {
        print('No constructions fetched');
        return;
      }
      String localisations =
          jsonEncode(myLocalisations.map((c) => c.toMap()).toList());
      String constructions = jsonEncode(myConstructions);
      print('Data: $localisations'); // Check the data
      print('Data: $constructions'); // Check the data

      await _controller.webViewController
          .runJavascript("displayLocalisations($localisations)");

      await _controller.webViewController
          .runJavascript("displayConstructions($constructions)");
    } catch (e) {
      print('Error fetching constructions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Superviseur"),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: WebViewPlus(
        onWebViewCreated: (controller) {
          _controller = controller;
          fetch(); // Move the call here
        },
        initialUrl: 'assets/Web/superviseur.html',
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: <JavascriptChannel>{
          JavascriptChannel(
            name: 'onMarkerAdded',
            onMessageReceived: (JavascriptMessage message) {
              print('Message received from JavaScript: ${message.message}');
              var coordinates = jsonDecode(message.message);
              try {
                setState(() {
                  _lat = normalizeDoubleString(coordinates[0].toString());
                  _lng = normalizeDoubleString(coordinates[1].toString());
                });
              } catch (e) {
                print('Error parsing double: $e');
              }
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: ConstructionForm(
                        lat: _lat,
                        lng: _lng,
                        onSubmit: (localisation) async {
                          await MongoHelpers.instance.create(localisation);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        },
      ),
    );
  }

  String normalizeDoubleString(String value) {
    return value.replaceAll(',', '.');
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
