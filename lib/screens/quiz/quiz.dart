import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';

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
      appBar: buildAppBar(context, 'Quiz'),

      body: RawScrollbar(
        isAlwaysShown: true,
        thumbColor: Color.fromRGBO(22, 66, 139, 1),
        //radius: Radius.circular(20),
        thickness: 7.5,

        child: Column(
          children: [
            Material(
              elevation: 20,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(22, 66, 139, 1),
                    border: Border(
                      bottom: BorderSide(
                        width: 1.5,
                        color: Color.fromRGBO(31, 31, 31, 1.0),
                      ),
                    )
                ),

                child: const Text(
                  'Pub Quiz',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            Expanded(
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: const [
                                  Text(
                                    'Join Quiz',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          )),
                    ),
                    Container(
                      height: 250,
                      child: Card(
                          margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: InkWell(
                            onTap: () {
                              //Navigator.pushNamed(context, '/quiz/leaderboards');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: const [
                                  Text(
                                    'Leaderboards',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          )),
                    ),
                    Container(
                      height: 250,
                      child: Card(
                          margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: InkWell(
                            onTap: () {
                              //Navigator.pushNamed(context, '/quiz/myTeam');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(children: const [
                                  Text(
                                    'My Team',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
