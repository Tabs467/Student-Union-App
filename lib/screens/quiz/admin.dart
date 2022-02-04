import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';

class QuizAdmin extends StatefulWidget {
  const QuizAdmin({Key? key}) : super(key: key);

  @override
  _QuizAdminState createState() => _QuizAdminState();
}

class _QuizAdminState extends State<QuizAdmin> {
  // Asynchronous function to start the given quiz
  Future startQuiz() async {
    await DatabaseService().startQuiz('i0VXURC5VW3DATZpge1T');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      body: RawScrollbar(
        isAlwaysShown: true,
        thumbColor: const Color.fromRGBO(22, 66, 139, 1),
        thickness: 7.5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                child: buildTabTitle('Quiz Admin Panel'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 0.0),
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Card(
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: Ink.image(
                        image:
                            const AssetImage('assets/start_continue_quiz.png'),
                        fit: BoxFit.fill,
                        child: InkWell(
                            splashColor: Colors.black.withOpacity(.3),
                            // When the Start/Continue button is tapped start the given
                            // quiz and push the user to the Quiz Control tab
                            onTap: () async {
                              await startQuiz();
                              Navigator.pushNamed(
                                  context, '/quiz/admin/quizControl');
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
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: Ink.image(
                        image: const AssetImage('assets/edit_quizzes.png'),
                        fit: BoxFit.fill,
                        child: InkWell(
                            splashColor: Colors.black.withOpacity(.3),
                            // When the Edit Quiz button is tapped push the user to the
                            // Edit Quizzes tab
                            onTap: () {
                              Navigator.pushNamed(context, '/quiz/admin/editQuizzes');
                            }),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
