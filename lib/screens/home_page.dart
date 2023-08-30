import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/2.png'),
                    fit: BoxFit.cover
                  )
                ),
              ),
              // Positioned(
              //   left: 10,
              //   top: 10,
              // child: IconButton(
              //   onPressed: (){},
              //   icon:  Icon(Icons.settings,size: 35, color: Colors.grey,),),)
               ]
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  children: [
                    SizedBox(height: 50,),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.of(context).pushNamed('/fallDetect');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('Fall Detection',style: TextStyle(
                            fontSize: 25
                        ),),
                      ) ,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal
                      ),),
                    SizedBox(height: 50,),
                    ElevatedButton(
                      onPressed: (){},
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text('Fall Prevention',style: TextStyle(
                            fontSize: 25
                        ),),
                      ) ,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent
                      ),),
                  ],
                ),
              ),
            )

         ],
        ),
      ),
    );
  }
}