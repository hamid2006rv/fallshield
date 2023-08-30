import 'dart:io';

import 'package:fallshiled/screens/fall_detection_page.dart';
import 'package:fallshiled/screens/home_page.dart';
import 'package:fallshiled/screens/introduction_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';

void main() async{

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<CameraDescription> _cameras = await availableCameras();

  runApp(MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Fallshiled',
              home: Introduction_page(),
              routes: {
                '/home': (ctx) => Home(),
                '/fallDetect': (ctx) => FallDetection_Screen(_cameras[0])
              },
            ));
}


