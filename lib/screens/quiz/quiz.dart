import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';

class Quiz extends StatefulWidget {
  const Quiz({Key? key}) : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

bool noActiveQuiz = true;

class _QuizState extends State<Quiz> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      body: StreamBuilder<QuerySnapshot>(
          // Data stream consists of all the Quiz documents whose 'isActive' boolean
          // is set to True

          // This will only ever return one document
          // Either an active quiz or the Quiz document that is used to mark that
          // there isn't a quiz currently active
          stream: FirebaseFirestore.instance
              .collection('Quizzes')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Something went wrong whilst checking whether a quiz is currently active');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Checking for active quiz...');
            }

            return RawScrollbar(
              isAlwaysShown: true,
              thumbColor: const Color.fromRGBO(22, 66, 139, 1),
              thickness: 7.5,
              child: SingleChildScrollView(
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
                            )),
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
                    ListView(
                        // List View shouldn't be scrollable as it will only ever
                        // contain one element (an active quiz button or a
                        // 'No Active Quiz' card)
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;

                          // If the active quiz is currently the Quiz document
                          // that is used to mark that there isn't a quiz currently active
                          if (data['id'] == 'cy7RWIJ3VGIXlHSM1Il8') {
                            // Then no quiz is currently active
                            noActiveQuiz = true;
                          }
                          // Otherwise if the active quiz is a different Quiz document
                          // (a real quiz)
                          else {
                            // Then a quiz is currently active
                            noActiveQuiz = false;
                          }

                          // If there is no active quiz display the 'No Active Quiz' card
                          return (noActiveQuiz)
                              ? SizedBox(
                                  height: 250,
                                  child: Card(
                                      margin: const EdgeInsets.fromLTRB(
                                          16.0, 8.0, 16.0, 8.0),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(children: const [
                                              Text(
                                                'No Active Quiz',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30,
                                                ),
                                              )
                                            ]),
                                          ],
                                        ),
                                      )),
                                )
                              // Otherwise, display a button to join the active quiz
                              : SizedBox(
                                  height: 250,
                                  child: Card(
                                      margin: const EdgeInsets.fromLTRB(
                                          16.0, 8.0, 16.0, 8.0),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/quiz/activeQuiz');
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
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
                                );
                        }).toList()),
                    SizedBox(
                      height: 250,
                      child: Card(
                          margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
                    SizedBox(
                      height: 250,
                      child: Card(
                          margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
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
            );
          }),
      floatingActionButton: SizedBox(
        height: 200.0,
        width: 200.0,
        child: FittedBox(
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/quiz/admin');
            },
            backgroundColor: const Color.fromRGBO(22, 66, 139, 1),
            label: const Text('Admin Controls'),
            icon: const Icon(Icons.admin_panel_settings_rounded),
          ),
        ),
      ),
    );
  }
}
