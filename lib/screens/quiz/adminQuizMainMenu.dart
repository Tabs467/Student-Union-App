import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/Quiz.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';

class AdminQuizMainMenu extends StatefulWidget {
  const AdminQuizMainMenu({Key? key}) : super(key: key);

  @override
  _AdminQuizMainMenuState createState() => _AdminQuizMainMenuState();
}

bool noActiveQuiz = true;

// Widget to display the Quiz Main Menu screen including the admin floating
// action button
class _AdminQuizMainMenuState extends State<AdminQuizMainMenu> {
  final DatabaseService _database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      body: StreamBuilder<QuerySnapshot>(
          // Data stream consists of all the Quiz documents whose 'isActive' boolean
          // is set to True

          // This will only ever return one document which is either
          // an active quiz or the Quiz document that is used to mark that
          // there isn't a quiz currently active
          stream: _database.getActiveQuiz(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Something went wrong whilst checking whether a quiz is currently active');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitRing(
                color: Colors.white,
                size: 150.0,
              );
            }

            return RawScrollbar(
              isAlwaysShown: true,
              thumbColor: const Color.fromRGBO(22, 66, 139, 1),
              thickness: 7.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                      child: buildTabTitle('Pub Quiz', 40),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 0.0),
                      child: ListView(
                          // List View shouldn't be scrollable as it will only ever
                          // contain one element (an active quiz button or a
                          // 'No Active Quiz' card)
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;

                            Quiz quiz = _database.quizFromSnapshot(data);

                            // If the active quiz is currently the Quiz document
                            // that is used to mark that there isn't a quiz currently active
                            if (quiz.id == 'cy7RWIJ3VGIXlHSM1Il8') {
                              // Then no quiz is currently active
                              noActiveQuiz = true;
                            }
                            // Otherwise if the active quiz is a different Quiz document
                            // (a real quiz)
                            else {
                              // Then a quiz is currently active
                              noActiveQuiz = false;
                            }

                            // If there is no active quiz display the
                            // No Active Quiz card
                            return (noActiveQuiz)
                                ? SizedBox(
                                    height: 250,
                                    child: Card(
                                        margin: const EdgeInsets.fromLTRB(
                                            16.0, 8.0, 16.0, 8.0),
                                        child: Ink.image(
                                          image: const AssetImage(
                                              'assets/no_active_quiz.png'),
                                          fit: BoxFit.fill,
                                          child: InkWell(
                                              splashColor:
                                                  Colors.black.withOpacity(.3),
                                              onTap: () {}),
                                        )))
                                // Otherwise, display a button to join the active quiz
                                : SizedBox(
                                    height: 250,
                                    width: double.infinity,
                                    child: Card(
                                        margin: const EdgeInsets.fromLTRB(
                                            16.0, 8.0, 16.0, 8.0),
                                        child: Ink.image(
                                          image: const AssetImage(
                                              'assets/join_quiz.png'),
                                          fit: BoxFit.fill,
                                          child: InkWell(
                                              splashColor:
                                                  Colors.black.withOpacity(.3),
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    '/quiz/activeQuiz');
                                              }),
                                        )),
                                  );
                          }).toList()),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 0.0),
                      child: SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Card(
                            margin:
                                const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                            child: Ink.image(
                              image:
                                  const AssetImage('assets/leaderboards.png'),
                              fit: BoxFit.fill,
                              child: InkWell(
                                  splashColor: Colors.black.withOpacity(.3),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/quiz/leaderboards');
                                  }),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 0.0),
                      child: SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Card(
                            margin:
                                const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                            child: Ink.image(
                              image: const AssetImage('assets/my_team.png'),
                              fit: BoxFit.fill,
                              child: InkWell(
                                  splashColor: Colors.black.withOpacity(.3),
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/quiz/myTeam');
                                  }),
                            )),
                      ),
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
