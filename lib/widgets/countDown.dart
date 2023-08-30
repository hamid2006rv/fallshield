import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CountDownWidget extends StatefulWidget {
  const CountDownWidget({Key? key}) : super(key: key);

  @override
  State<CountDownWidget> createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  int counter = 60;
  int max_count = 60;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) {
          counter--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.red,
      title: const Center(
        child: Icon(
          RpgAwesome.ringing_bell,
          color: Colors.white,
          size: 50,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'FALL DETECTED!',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25),
          ),
          SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'I\'m OK',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  CircularPercentIndicator(
                    radius: 18.0,
                    lineWidth: 3.0,
                    percent: counter / max_count,
                    center: new Text("$counter", style: TextStyle(color: Colors.white),),
                    progressColor: Colors.white,
                  ),
                ],
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // <-- Radius
              ),
            ),
          ),
        ],
      ),
    );
  }
}
