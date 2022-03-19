import 'package:flutter/material.dart';
import 'package:student_union_app/models/MultipleChoiceQuestion.dart';
import 'package:student_union_app/models/NearestWinsQuestion.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class EditQuestion extends StatefulWidget {
  final Question question;

  const EditQuestion({Key? key, required this.question}) : super(key: key);

  @override
  _EditQuestionState createState() => _EditQuestionState();
}

// Widget to display a form to edit an existing question
class _EditQuestionState extends State<EditQuestion> {
  final DatabaseService _database = DatabaseService();

  String questionID = '';

  // Text field state
  String questionText = '';
  String answerA = '';
  String answerB = '';
  String answerC = '';
  String answerD = '';
  double correctNWQAnswer = 0;
  String error = '';

  // Radio button group state
  String correctMCQAnswer = '';
  String questionType = '';


  final _formKey = GlobalKey<FormState>();


  // Check whether a given string is a Numeric
  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }

    return double.tryParse(str) != null;
  }


  // Set initial values of text field and radio button states to the parameters
  // passed to this Widget
  @override
  void initState() {

    // Determine the type of question and cast it either as a multiple choice or
    // nearest wins question
    if (widget.question.questionType == "MCQ") {
      MultipleChoiceQuestion question = widget.question as MultipleChoiceQuestion;

      questionID = question.id!;

      questionText = question.questionText!;
      answerA = question.answerA!;
      answerB = question.answerB!;
      answerC = question.answerC!;
      answerD = question.answerD!;
      correctMCQAnswer = question.correctAnswer!;
      questionType = question.questionType!;
    }
    else if (widget.question.questionType == "NWQ") {
      NearestWinsQuestion question = widget.question as NearestWinsQuestion;

      questionID = question.id!;

      questionText = question.questionText!;
      correctNWQAnswer = question.correctAnswer!;
      questionType = question.questionType!;
    }

    super.initState();
  }

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
              child: buildTabTitle('Edit Question', 40),
            ),
            // Radio buttons for the type of question
            // When changed the form will rebuilt for the correct type of
            // question
            ButtonBar(children: [
              Row(
                children: [
                  const Text('Multiple Choice:'),
                  Radio(
                    value: 'MCQ',
                    groupValue: questionType,
                    activeColor: const Color.fromRGBO(22, 66, 139, 1),
                    onChanged: (T) {
                      setState(() {
                        questionType = 'MCQ';
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Nearest Wins:'),
                  Radio(
                    value: 'NWQ',
                    groupValue: questionType,
                    activeColor: const Color.fromRGBO(22, 66, 139, 1),
                    onChanged: (T) {
                      setState(() {
                        questionType = 'NWQ';
                      });
                    },
                  ),
                ],
              ),
            ]),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: questionText,
                      decoration: const InputDecoration(
                        hintText: 'Question Text',
                      ),
                      // Question text cannot be empty and must be
                      // below 70 characters
                      validator: (String? value) {
                        if (value != null && value.trim() == '') {
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

                    // If multiple choice question has been selected, display
                    // the form fields suitable for it
                    (questionType == "MCQ") ?
                    Column(
                      children: [
                        TextFormField(
                          initialValue: answerA,
                          decoration: const InputDecoration(
                            hintText: 'Answer A',
                          ),
                          // Answer A cannot be empty and must be
                          // below 50 characters
                          validator: (String? value) {
                            if (value != null && value.trim() == '') {
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
                          initialValue: answerB,
                          decoration: const InputDecoration(
                            hintText: 'Answer B',
                          ),
                          // Answer B cannot be empty and must be
                          // below 50 characters
                          validator: (String? value) {
                            if (value != null && value.trim() == '') {
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
                          initialValue: answerC,
                          decoration: const InputDecoration(
                            hintText: 'Answer C',
                          ),
                          // Answer C cannot be empty and must be
                          // below 50 characters
                          validator: (String? value) {
                            if (value != null && value.trim() == '') {
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
                          initialValue: answerD,
                          decoration: const InputDecoration(
                            hintText: 'Answer D',
                          ),
                          // Answer D cannot be empty and must be
                          // below 50 characters
                          validator: (String? value) {
                            if (value != null && value.trim() == '') {
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
                        ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  const Text('A:'),
                                  Radio(
                                    value: 'a',
                                    groupValue: correctMCQAnswer,
                                    activeColor: const Color.fromRGBO(22, 66, 139, 1),
                                    onChanged: (T) {
                                      setState(() {
                                        correctMCQAnswer = 'a';
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
                                    groupValue: correctMCQAnswer,
                                    activeColor: const Color.fromRGBO(22, 66, 139, 1),
                                    onChanged: (T) {
                                      setState(() {
                                        correctMCQAnswer = 'b';
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
                                    groupValue: correctMCQAnswer,
                                    activeColor: const Color.fromRGBO(22, 66, 139, 1),
                                    onChanged: (T) {
                                      setState(() {
                                        correctMCQAnswer = 'c';
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
                                    groupValue: correctMCQAnswer,
                                    activeColor: const Color.fromRGBO(22, 66, 139, 1),
                                    onChanged: (T) {
                                      setState(() {
                                        correctMCQAnswer = 'd';
                                      });
                                    },
                                  ),
                                ],
                              ),
                        ]),
                      ],
                    )

                    // If nearest wins question has been selected, display
                    // the form fields suitable for it
                    : Column(
                      children: [
                        const SizedBox(height: 10.0),
                        TextFormField(
                          initialValue: correctNWQAnswer.toString(),
                          decoration: const InputDecoration(
                            hintText: 'Correct Answer',
                          ),
                          // NWQ answer cannot be empty and must be a number
                          // And must be below 17 characters
                          validator: (String? value) {
                            if (value != null && value.trim() == '') {
                              return "Question Answer cannot be empty!";
                            } else if (value!.length > 17) {
                              return "Question Answer must be below 17 characters!";
                            }
                            else if (!_isNumeric(value)) {
                              return "Correct Answer must be a number!";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              correctNWQAnswer = double.parse(val);
                            });
                          },
                        ),
                      ],
                    ),
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
                      child: const Text('Submit Changes'),
                      // When the Submit Changes button is tapped, check
                      // whether the question details are valid and update the
                      // question document to the new validated details
                      // And return the user back to the EditQuiz screen
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {

                          // If the edited question is a multiple choice question
                          if (questionType == "MCQ") {
                            // Question number is not updated or retrieved here so
                            // setting it to 0 is fine
                            // The same goes for the quizID being set to 'Not Set'
                            MultipleChoiceQuestion question = MultipleChoiceQuestion(
                              id: questionID,
                              answerA: answerA,
                              answerB: answerB,
                              answerC: answerC,
                              answerD: answerD,
                              correctAnswer: correctMCQAnswer,
                              questionNumber: 0,
                              questionText: questionText,
                              quizID: 'Not Set',
                            );

                            await _database.updateMultipleChoiceQuestion(question);
                          }

                          // If the edited question is a nearest wins question
                          else if (questionType == "NWQ") {
                            // Question number is not updated or retrieved here so
                            // setting it to 0 is fine
                            // The same goes for the quizID being set to 'Not Set'
                            NearestWinsQuestion question = NearestWinsQuestion(
                              id: questionID,
                              correctAnswer: correctNWQAnswer,
                              questionNumber: 0,
                              questionText: questionText,
                              quizID: 'Not Set',
                            );

                            await _database.updateNearestWinsQuestion(question);
                          }

                          // Return to the Edit Questions Widget
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
