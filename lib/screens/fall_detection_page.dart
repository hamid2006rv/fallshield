import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:fallshiled/widgets/countDown.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FallDetection_Screen extends StatefulWidget {
  final CameraDescription camera;
  const FallDetection_Screen(this.camera) ;

  @override
  State<FallDetection_Screen> createState() => _FallDetection_ScreenState();
}

class _FallDetection_ScreenState extends State<FallDetection_Screen> {

  final dylib = Platform.isAndroid
      ? DynamicLibrary.open("libOpenCV_ffi.so")
      : DynamicLibrary.process();


  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isStreaming = false;

  Image _img = Image.asset('assets/images/map.jpeg');
  bool _detectionInProgress = false;
  int _lastRun = 0;

  Pointer<Uint8>? _imageBuffer;
  Pointer<Uint8>? _old_frame = nullptr;
  Pointer<Uint8>? _frame = nullptr;
  late Uint8List _old_frame_bytes ;
  late Uint8List _frame_bytes ;
  Pointer<Uint32> p0size = malloc.allocate(1);
  Pointer<Float> p0 = malloc.allocate(700);
  int count = 0;
  int e0 = -1;
  int e1 = -1;
  int threshold = 4 ;

  int total_time = 0 ;
  List<int> logs = [];

  Timer? _timer;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,  (Timer timer) {
        setState(() {
          total_time +=1 ;
        });
     });
   }

   void stopTimer(){
     _timer!.cancel();
     _controller.stopImageStream();
   }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }


  showAlert(BuildContext context)
  {
    FlutterRingtonePlayer.play(fromAsset: "assets/alarm.wav", volume: 1);
    setState(() {
      _isStreaming = false;
    });
    stopTimer();
    print(logs);

    showDialog(
        context: context,
        builder: (BuildContext context)
        {
          return CountDownWidget();
        /*return AlertDialog(


        );*/
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller = CameraController(
        widget.camera,
        ResolutionPreset.low,
        imageFormatGroup: Platform.isIOS?ImageFormatGroup.bgra8888:ImageFormatGroup.yuv420,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.stopImageStream();
    _controller.dispose();
    malloc.free(_old_frame!);
    malloc.free(p0size!);
    malloc.free(p0!);
    malloc.free(_frame!);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final opticalflowEvent = dylib.lookupFunction<
        Int32 Function(Int32 , Int32 , Pointer<Uint8> , Pointer<Uint8>, Pointer<Float>, Pointer<Uint32>),
        int Function(
            int , int, Pointer<Uint8>, Pointer<Uint8>, Pointer<Float>, Pointer<Uint32>)>('opticalflowEvent');

    final getFeatures = dylib.lookupFunction<
        Void Function(Int32 , Int32 , Pointer<Uint8> , Pointer<Float>, Pointer<Uint32>),
        void Function(
            int , int, Pointer<Uint8>, Pointer<Float>, Pointer<Uint32>)>('getFeatures');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white54,
        elevation: 0,
        foregroundColor: Colors.teal,
        actions: [IconButton(onPressed: (){}, icon: Icon(Icons.settings))],
      ),
      body: Column (
        children: [
               SizedBox(height: 20,),
               CircleAvatar(foregroundImage: AssetImage('assets/images/oldman.jpeg'),maxRadius: 45, ),
               SizedBox(height: 10,),
               Text('John Smith'),
               Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, color:Colors.green),
                          SizedBox(width:5 ,),
                          Text('vancouver 365 street')

                        ],
                      ),
               SizedBox(height: 10,),
               ElevatedButton(
                 onPressed: () async {
                   // Take the Picture in a try / catch block. If anything goes wrong,
                   // catch the error.
                   try {
                     // Ensure that the camera is initialized.
                     await _initializeControllerFuture;
                     if (_isStreaming) {
                       await _controller.stopImageStream();
                       print("Stopped");
                       setState(() {
                         _isStreaming = false;
                         total_time = 0;
                       });
                       stopTimer();
                     } else {
                       startTimer();
                       setState(() => _isStreaming = true);
                       print("Starting");

                       await _controller.startImageStream((CameraImage availableImage) async {
                         if (_detectionInProgress || !mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 100) {
                           return;
                         }
                         _detectionInProgress = true;
                         count +=1 ;
                         imglib.Image img = imglib.Image.fromBytes(height: availableImage.height,
                           width: availableImage.width,
                           bytes:Uint8List.fromList(availableImage.planes[0].bytes).buffer,
                           order: imglib.ChannelOrder.bgra,);
                         setState(() {
                           _img = Image.memory(imglib.encodeBmp(img));
                         });
                         if(_old_frame==nullptr)
                         {
                           var ySize = availableImage.planes[0].bytes.lengthInBytes;
                           _old_frame = malloc.allocate<Uint8>(ySize);
                           _old_frame_bytes = _old_frame!.asTypedList(ySize);
                           _old_frame_bytes.setAll(0, availableImage.planes[0].bytes);
                           // compute p0
                           int  width = availableImage.width;
                           int  height = availableImage.height;

                           getFeatures(width, height, _old_frame!, p0 , p0size);
                         }
                         else
                         {
                           // read frame
                           var ySize = availableImage.planes[0].bytes.lengthInBytes;
                           int  width = availableImage.width;
                           int  height = availableImage.height;
                           _frame = await malloc.allocate<Uint8>(ySize);
                           _frame_bytes = _frame!.asTypedList(ySize);
                           _frame_bytes.setAll(0, availableImage.planes[0].bytes);
                           //compute p1 with optical flow
                           int flag = opticalflowEvent(width,height,_old_frame!,_frame!,p0,p0size);
                           if(flag==0)
                           {
                             getFeatures(width, height, _frame!, p0 , p0size);
                             logs.add(count);
                             if(e0==-1 && e1==-1)
                               e0 = count;
                             else if(e1 == -1)
                             {
                               e1 = count;
                               if(e1 - e0 <=threshold)
                               {
                                 print('fall occures');
                                 showAlert(this.context);
                               }
                               e0 = -1;
                               e1 = -1;
                             }
                           }
                           //malloc.free(_old_frame!);
                           _old_frame_bytes =  _frame_bytes;
                           _old_frame = _frame;
                         }

                         _lastRun = DateTime.now().millisecondsSinceEpoch;
                         _detectionInProgress = false;
                       });
                     }
                   } catch (e) {
                     // If an error occurs, log the error to the console.
                     print(e);
                   }
                 },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                    ),
                    child:_isStreaming?
                    Text(
                      'Stop Monitoring',
                      style: TextStyle(
                        color: Colors.white, // Button text color
                        fontSize: 16.0,
                      )
                    )
                    :Text(
                      'Start Monitoring',
                      style: TextStyle(
                        color: Colors.white, // Button text color
                        fontSize: 16.0,
                      ),
                    ),
                  ),
               SizedBox(height: 20,),
               Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width - 30,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Total Monitoring Duration',
                            style: TextStyle(color:Colors.white) ,),
                          SizedBox(height: 5,),
                          Text(formatTime(total_time), style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),)
                        ],
                      ),
                    ),
                  ),
               Expanded(child: Container(
                 padding: EdgeInsets.all(10),
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image: AssetImage('assets/images/map.jpeg'),
                  //     fit: BoxFit.cover
                  //   )
                  // ),
                child: FutureBuilder<void> (
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Center(child: _img);
                    } else {
                      // Otherwise, display a loading indicator.
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ))
            ],
         )
    );
  }
}

