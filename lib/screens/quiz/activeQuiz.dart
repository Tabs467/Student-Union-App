import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import 'package:student_union_app/models/Question.dart';

class ActiveQuiz extends StatefulWidget {
  const ActiveQuiz({Key? key}) : super(key: key);

  @override
  _ActiveQuizState createState() => _ActiveQuizState();
}

class _ActiveQuizState extends State<ActiveQuiz> {

  String quizID = 'i0VXURC5VW3DATZpge1T';
  int currentQuestionNumber = 1;
  int questionCount = 10;
  bool quizEnded = false;

  initState() {
    retrieveCurrentQuestionNumber();
  }

  final Stream<QuerySnapshot> _quizzes = FirebaseFirestore.instance
      .collection('Quizzes')
      .where('isActive', isEqualTo: true)
      .snapshots();

  retrieveCurrentQuestionNumber() {
    setState(() {
      _quizzes.forEach((field) {
        field.docs.asMap().forEach((index, data) {
          currentQuestionNumber = data['currentQuestion'];
          questionCount = data['questionCount'];
          quizEnded = data['quizEnded'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Quizzes')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading');
                  }

                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                    currentQuestionNumber = data['currentQuestion'];
                  });

                  //return Text(currentQuestionNumber.toString());

                  return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Questions')
                          .where('quizID', isEqualTo: quizID)
                          .where('questionNumber',
                          isEqualTo: currentQuestionNumber)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading');
                        }

                        return RawScrollbar(
                          isAlwaysShown: true,
                          thumbColor: Color.fromRGBO(22, 66, 139, 1),
                          //radius: Radius.circular(20),
                          thickness: 7.5,

                          child: Column(
                            children: [
                              Expanded(
                                child: RawScrollbar(
                                  isAlwaysShown: true,
                                  thumbColor: Color.fromRGBO(22, 66, 139, 1),
                                  //radius: Radius.circular(20),
                                  thickness: 7.5,

                                  child: ListView(
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        Map<String, dynamic> data =
                                        document.data()! as Map<String, dynamic>;
                                        return Container(
                                          color:
                                          const Color.fromRGBO(244, 175, 20, 1.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Card(
                                                  color: const Color.fromRGBO(
                                                      22, 66, 139, 1),
                                                  elevation: 20,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Text(
                                                      'Q' +
                                                          data['questionNumber']
                                                              .toString() +
                                                          ': ' +
                                                          data['questionText'],
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(1),
                                                child: Card(
                                                  color: Colors.red[900],
                                                  elevation: 20,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {

                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(30.0),
                                                      child: Text(
                                                        'A: ' + data['answerA'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(1),
                                                child: Card(
                                                  color: Colors.blue[900],
                                                  elevation: 20,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {

                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(30.0),
                                                      child: Text(
                                                        'B: ' + data['answerB'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(1),
                                                child: Card(
                                                  color: Colors.green[900],
                                                  elevation: 20,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {

                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(30.0),
                                                      child: Text(
                                                        'C: ' + data['answerC'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(1),
                                                child: Card(
                                                  color: Colors.yellow[900],
                                                  elevation: 20,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {

                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(30.0),
                                                      child: Text(
                                                        'D: ' + data['answerD'],
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 30,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList()),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
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
              height: 70,
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
    );
  }
}
