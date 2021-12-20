import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/screens/buildAppBar.dart';

class ActiveQuiz extends StatefulWidget {
  const ActiveQuiz({Key? key}) : super(key: key);

  @override
  _ActiveQuizState createState() => _ActiveQuizState();
}

class _ActiveQuizState extends State<ActiveQuiz> {

  String quizID = '';
  int currentQuestionNumber = 1;
  int questionCount = 10;
  bool quizEnded = false;
  bool anyQuizActive = false;

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
          quizID = data['id'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),

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
                    return const Text('Something went wrong retrieving the quiz');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading the quiz...');
                  }

                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                    currentQuestionNumber = data['currentQuestion'];
                    quizEnded = data['quizEnded'];
                    quizID = data['id'];
                  });

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
                          return const Text('Something went wrong retrieving the question');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading the question...');
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
                                                    side: BorderSide(color: Colors.white70, width: 1),
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
                                                    BorderRadius.circular(0),
                                                    side: BorderSide(color: Colors.white70, width: 1),
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
                                                    BorderRadius.circular(0),
                                                    side: BorderSide(color: Colors.white70, width: 1),
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
                                                    BorderRadius.circular(0),
                                                    side: BorderSide(color: Colors.white70, width: 1),
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
                                                    BorderRadius.circular(0),
                                                    side: BorderSide(color: Colors.white70, width: 1),
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
    );
  }
}
