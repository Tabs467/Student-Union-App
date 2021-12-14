import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';

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
