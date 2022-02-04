import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class EditQuiz extends StatefulWidget {
  final String quizID;
  final String quizTitle;

  const EditQuiz({Key? key, required this.quizID, required this.quizTitle})
      : super(key: key);

  @override
  _EditQuizState createState() => _EditQuizState();
}

// Widget to display a form to edit a quiz title
// Along with a button that navigates to a Widget to edit the questions
// contained within the quiz
class _EditQuizState extends State<EditQuiz> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String quizTitle = '';
  String error = '';

  @override
  void initState() {
    quizTitle = widget.quizTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: buildTabTitle('Edit Quiz'),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: quizTitle,
                    decoration: const InputDecoration(
                      hintText: 'Quiz Title',
                    ),
                    // Quiz titles cannot be empty and must be
                    // below 40 characters
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return "Quiz Title cannot be empty!";
                      } else if (value!.length > 40) {
                        return "Quiz Title must be below 40 characters!";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        quizTitle = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
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
                    // When the Submit Changes button is tapped check whether
                    // the quiz name is valid and update the quiz document
                    // to the new quiz title
                    // And return the user back to the EditQuizzes screen
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _database.updateQuiz(widget.quizID, quizTitle);
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
            child: const Text('Edit Questions'),
            // Pass the quiz title and id to the EditQuestions Widget and
            // navigate to it
            onPressed: () async {
              /*Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditQuestions(quizID: widget.quizID,
                        quizTitle: widget.quizTitle,),
                ),
              );*/
            },
          ),
          // To create padding so the Return button is displayed at the bottom
          // of the screen
          Expanded(
            child: Container(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              maximumSize: const Size(200, 50),
              primary: const Color.fromRGBO(22, 66, 139, 1),
            ),
            child: const Text('Return'),
            // Return the user back to the EditQuizzes screen
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}