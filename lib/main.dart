import 'package:flutter/material.dart';
import 'package:myweatherapp/pages.dart/home.dart';
import 'package:myweatherapp/pages.dart/loading.dart';

//import 'package:myweatherapp/pages.dart/location.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loading(),
      routes: {
        "/home": (context) => Home(),
        "/loading": (context) => Loading(),
        //"/location": (context) => Location(),
      },
    ),
  );
}
