import 'package:flutter/material.dart';
import 'package:student_union_app/Models/MenuGroup.dart';
import 'package:student_union_app/Models/MenuSubGroup.dart';
import 'package:student_union_app/Models/MenuItem.dart';


class Mains extends StatefulWidget {
  const Mains({Key? key}) : super(key: key);

  @override
  _MainsState createState() => _MainsState();
}

class _MainsState extends State<Mains> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 175, 20, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(22, 66, 139, 1),
        //title: Image.asset('assets/US_SU_Logo.jpg', fit: BoxFit.fitWidth),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/US_SU_Logo.jpg',
              fit: BoxFit.contain,
              height:70,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Food/Drink',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),


        actions: <Widget>[

          IconButton(
            icon: const Icon(Icons.fastfood_rounded),
            tooltip: 'Food/Drink Menu',
            color: Color.fromRGBO(244, 175, 20, 1),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.quiz_rounded),
            tooltip: 'Pub Quiz',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/quiz');
            },
          ),

          IconButton(
            icon: const Icon(Icons.mic_external_on_rounded),
            tooltip: 'Bandaoke',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.emoji_emotions_rounded),
            tooltip: 'Comedy Night',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.campaign_rounded),
            tooltip: 'News',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Login/Register',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          )
        ],
      ),

      body: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/mains');
              },
              child: Container(
                height: 200,
                child: Card(
                    margin: EdgeInsets.all(16.0),
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            children: const [
                              Text(
                                'Burgers',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            ]
                        ),
                        Image.asset(
                          'assets/Burgers.jpg',
                          fit: BoxFit.contain,
                          height:70,
                        ),
                      ],
                    )
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/menu/mains');
              },
              child: Container(
                height: 200,
                child: Card(
                    margin: EdgeInsets.all(16.0),
                    child: Row (
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                            children: const [
                              Text(
                                'Pizzas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 40,
                                ),
                              ),
                            ]
                        ),
                        Image.asset(
                          'assets/Pizzas.png',
                          fit: BoxFit.fitHeight,
                          height: 200,
                        ),
                      ],
                    )
                ),
              ),
            )
          ]
      ),

    );
  }
}


