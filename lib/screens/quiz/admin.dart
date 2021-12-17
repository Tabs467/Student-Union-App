import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import 'package:student_union_app/screens/buildAppBar.dart';

class QuizAdmin extends StatefulWidget {
  const QuizAdmin({Key? key}) : super(key: key);

  @override
  _QuizAdminState createState() => _QuizAdminState();
}

class _QuizAdminState extends State<QuizAdmin> {

  Future startQuiz() async {
    await DatabaseService().startQuiz('i0VXURC5VW3DATZpge1T');
  }

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
                      )
                  ),

                  child: const Text(
                    'Quiz Admin Panel',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Container(
                height: 250,
                child: Card(
                    margin: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: InkWell(
                      onTap: () async {
                        await startQuiz();
                        Navigator.pushNamed(context, '/quiz/admin/quizControl');
                      },
                      child: Row (
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              children: const [
                                Text(
                                  'Start Quiz',
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
                        //Navigator.pushNamed(context, '/quiz/admin/editQuizzes');
                      },
                      child: Row (
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              children: const [
                                Text(
                                  'Edit Quizzes',
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
    );
  }
}
