import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';


class Introduction_page extends StatelessWidget {
  const Introduction_page({Key? key}) : super(key: key);

  //widget to add the image on screen
  Widget buildImage(String imagePath) {
    return Center(
        child: Container(
          width: 450,
          height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ));
  }

  //method to customize the dots style
  DotsDecorator getDotsDecorator() {
    return const DotsDecorator(
      spacing: EdgeInsets.symmetric(horizontal: 2),
      activeColor: Colors.indigo,
      color: Colors.grey,
      activeSize: Size(12, 5),
      activeShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: 'Intelligent Fall Detection',
            bodyWidget: Text('Our app\'s sophisticated image processing algorithms and accelerometer integration work harmoniously to accurately detect falls in real-time. Your loved ones are never alone, even when you\'re not by their side.',
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            image: buildImage("assets/images/1.png"),
          ),
          PageViewModel(
            title: 'Instant Location Alert',
            bodyWidget: Text('In the event of a fall, FallShield swiftly sends an alarm along with the exact location to your designated contacts. Help arrives faster, minimizing the impact of accidents.',
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            image: buildImage("assets/images/2.png"),
          ),
        ],
          onDone: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
          //ClampingScrollPhysics prevent the scroll offset from exceeding the bounds of the content.
          scrollPhysics: const ClampingScrollPhysics(),
          showDoneButton: true,
          showNextButton: true,
          showSkipButton: true,
          isBottomSafeArea: true,
          skip:
          const Text("Skip", style: TextStyle(fontWeight: FontWeight.w600)),
          next: const Icon(Icons.forward),
          done:
          const Text("Start", style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: getDotsDecorator()),
    );
  }
}
