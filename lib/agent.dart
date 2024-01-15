import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../models/constructions.dart';
import '../mongoHelpers/mongoHelpers.dart';

class Agent extends StatefulWidget {
  @override
  _AgentState createState() => _AgentState();
}

class _AgentState extends State<Agent> {
  InAppWebViewController? webViewController;

  Future<List<Map<String, dynamic>>> getGeoJSONFromDatabase() async {
    return await MongoHelpers.instance.readAllConstructions();
  }

  Future<List<Map<String, dynamic>>> getLocalisationsFromDatabase() async {
    return await MongoHelpers.instance.readAllforUser();
  }

  Future<String> convertGeoJSONToJSArray() async {
    List<Map<String, dynamic>> geoJSONList = await getGeoJSONFromDatabase();
    String jsArray = jsonEncode(geoJSONList);
    print("Here is your list OVER HEEERE $jsArray");
    return jsArray;
  }

  Future<String> convertLocalisationJSONToJSArray() async {
    List<Map<String, dynamic>> geoJSONList =
        await getLocalisationsFromDatabase();
    String jsArray = jsonEncode(geoJSONList);
    print("Here is your list OVER HEEERE $jsArray");
    return jsArray;
  }

  Future<void> sendGeoJSONToWebView() async {
    String jsArray = await convertGeoJSONToJSArray();
    String localisations = await convertLocalisationJSONToJSArray();
    webViewController?.evaluateJavascript(source: "displayGeoJSON($jsArray);");
    webViewController?.evaluateJavascript(
        source: "displayLocalisations($localisations);");
    webViewController?.evaluateJavascript(source: 'display($jsArray);');
    print('localisations SENT TO WEB VIEW :$localisations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agent Window')),
      body: InAppWebView(
        initialFile: "assets/Web/agent.html",
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
        onWebViewCreated: (controller) async {
          webViewController = controller;
          await sendGeoJSONToWebView();
        },
        onLoadStop: (controller, url) async {
          print('TEST TEST');
          await sendGeoJSONToWebView();
          controller.addJavaScriptHandler(
            handlerName: 'sendMessageToFlutter',
            callback: (data) async {
              print('TEST DATA: $data');
              Map<String, dynamic> jsonDataList =
                  json.decode(data.first as String);
              print('jsonDataList: $jsonDataList');
              Construction construction = Construction(
                type: 'Feature',
                type_construction: jsonDataList['properties']['type'],
                address: jsonDataList['properties']['address'],
                contact: jsonDataList['properties']['contact'],
                geometry: jsonDataList['geometry'],
              );

              print('TEST construction: $construction');
              await MongoHelpers.instance.insertConstruction(construction);
              sendGeoJSONToWebView();
              controller.evaluateJavascript(source: 'sendResponseToWeb();');
            },
          );
        },
      ),
    );
  }
}
