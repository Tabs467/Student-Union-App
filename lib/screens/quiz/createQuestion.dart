import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class CreateQuestion extends StatefulWidget {
  final String quizID;
  final String questionCount;

  const CreateQuestion(
      {Key? key, required this.quizID, required this.questionCount})
      : super(key: key);

  @override
  _CreateQuestionState createState() => _CreateQuestionState();
}

// Widget to display a form to create a new question
class _CreateQuestionState extends State<CreateQuestion> {
  final DatabaseService _database = DatabaseService();

  String quizID = '';
  String questionCount = '';

  @override
  void initState() {
    quizID = widget.quizID;
    questionCount = widget.questionCount;
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String questionText = '';
  String answerA = '';
  String answerB = '';
  String answerC = '';
  String answerD = '';
  String error = '';

  // Radio button group state
  String correctAnswer = 'a';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: buildTabTitle('Create Question'),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Question Text',
                      ),
                      // Question text cannot be empty and must be
                      // below 70 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Question Text cannot be empty!";
                        } else if (value!.length > 70) {
                          return "Question Text must be below 70 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          questionText = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Answer A',
                      ),
                      // Answer A cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer A cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer A must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerA = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Answer B',
                      ),
                      // Answer B cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer B cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer B must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerB = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Answer C',
                      ),
                      // Answer C cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer C cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer C must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerC = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Answer D',
                      ),
                      // Answer D cannot be empty and must be
                      // below 50 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Answer D cannot be empty!";
                        } else if (value!.length > 50) {
                          return "Answer D must be below 50 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          answerD = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      'Correct Answer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Radio buttons for the correct answer
                    ButtonBar(children: [
                      Row(
                        children: [
                          const Text('A:'),
                          Radio(
                            value: 'a',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'a';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('B:'),
                          Radio(
                            value: 'b',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'b';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('C:'),
                          Radio(
                            value: 'c',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'c';
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('D:'),
                          Radio(
                            value: 'd',
                            groupValue: correctAnswer,
                            activeColor: const Color.fromRGBO(22, 66, 139, 1),
                            onChanged: (T) {
                              setState(() {
                                correctAnswer = 'd';
                              });
                            },
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 6.0),
                    // Error text
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18.0,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Create Question'),
                      // When the Create Question button is tapped, check
                      // whether the question details are valid and create a
                      // new question document that contains the
                      // validated information
                      // And return the user back to the EditQuiz screen
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          int questionNumber = int.parse(questionCount) + 1;
                          await _database.createQuestion(
                              quizID,
                              questionNumber,
                              questionText,
                              correctAnswer,
                              answerA,
                              answerB,
                              answerC,
                              answerD);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                primary: const Color.fromRGBO(22, 66, 139, 1),
              ),
              child: const Text('Return'),
              // Return the user back to the EditQuiz screen
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 25.0),
          ],
        ),
      ),
    );
  }
}
