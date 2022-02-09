import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';

class QuizAdmin extends StatefulWidget {
  const QuizAdmin({Key? key}) : super(key: key);

  @override
  _QuizAdminState createState() => _QuizAdminState();
}

// Widget to display buttons to start or continue a pub quiz and a button to
// open the quiz editor Widget
class _QuizAdminState extends State<QuizAdmin> {
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

            bool noActiveQuiz = false;
            if (snapshot.data!.docs.isNotEmpty) {
              if (snapshot.data!.docs[0]['id'] != null) {
                // If the active quiz is currently the Quiz document
                // that is used to mark that there isn't a quiz currently active
                if (snapshot.data!.docs[0]['id'] == 'cy7RWIJ3VGIXlHSM1Il8') {
                  // Then no quiz is currently active
                  noActiveQuiz = true;
                }
              }
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
                      child: buildTabTitle('Quiz Admin Panel'),
                    ),
                    // If there is no active quiz display the Start Quiz button
                    (noActiveQuiz)
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 0.0),
                            child: SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: Card(
                                  margin: const EdgeInsets.fromLTRB(
                                      16.0, 8.0, 16.0, 8.0),
                                  child: Ink.image(
                                    image: const AssetImage(
                                        'assets/start_quiz.png'),
                                    fit: BoxFit.fill,
                                    child: InkWell(
                                        splashColor:
                                            Colors.black.withOpacity(.3),
                                        // When the Start button is tapped
                                        // push the user to the SelectQuiz
                                        // Widget
                                        onTap: () async {
                                          Navigator.pushNamed(context,
                                              '/quiz/admin/selectQuiz');
                                        }),
                                  )),
                            ),
                          )
                        // If there is an active quiz display the continue
                        // quiz button
                        : Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 0.0),
                            child: SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: Card(
                                  margin: const EdgeInsets.fromLTRB(
                                      16.0, 8.0, 16.0, 8.0),
                                  child: Ink.image(
                                    image: const AssetImage(
                                        'assets/continue_quiz.png'),
                                    fit: BoxFit.fill,
                                    child: InkWell(
                                        splashColor:
                                            Colors.black.withOpacity(.3),
                                        // When the Continue button is tapped
                                        // push the user to the Quiz Control tab
                                        onTap: () async {
                                          Navigator.pushNamed(context,
                                              '/quiz/admin/quizControl');
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
                              image:
                                  const AssetImage('assets/edit_quizzes.png'),
                              fit: BoxFit.fill,
                              child: InkWell(
                                  splashColor: Colors.black.withOpacity(.3),
                                  // When the Edit Quiz button is tapped push the user to the
                                  // Edit Quizzes tab
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/quiz/admin/editQuizzes');
                                  }),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}