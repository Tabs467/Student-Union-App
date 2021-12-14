import 'package:flutter/material.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
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
                'Pub Quiz',
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
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.quiz_rounded),
            tooltip: 'Pub Quiz',
            color: Color.fromRGBO(244, 175, 20, 1),
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

      body: RawScrollbar(
        isAlwaysShown: true,
        thumbColor: Color.fromRGBO(22, 66, 139, 1),
        //radius: Radius.circular(20),
        thickness: 7.5,

        child: SingleChildScrollView(
          child: Column(
            children: [
                Container(
                  height: 250,
                  child: Card(
                      margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/quiz/activeQuiz');
                        },
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                                children: const [
                                  Text(
                                    'Join Quiz',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ]
                            ),
                          ],
                        ),
                      )
                  ),
                ),

              Container(
                height: 250,
                child: Card(
                    margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: InkWell(
                      onTap: () {
                        //Navigator.pushNamed(context, '/quiz/leaderboards');
                      },
                      child: Row (
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              children: const [
                                Text(
                                  'Leaderboards',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                    )
                ),
              ),

              Container(
                height: 250,
                child: Card(
                    margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: InkWell(
                      onTap: () {
                        //Navigator.pushNamed(context, '/quiz/myTeam');
                      },
                      child: Row (
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              children: const [
                                Text(
                                  'My Team',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ]
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ],
          ),
        ),
      ),


      floatingActionButton: Container(
        height: 200.0,
        width: 200.0,
        child: FittedBox(
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/quiz/admin');
            },
            backgroundColor: Color.fromRGBO(22, 66, 139, 1),
            label: const Text('Admin Controls'),
            icon: const Icon(Icons.admin_panel_settings_rounded),
          ),
        ),
      ),
    );
  }
}
