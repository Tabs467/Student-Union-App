import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class CreateQuiz extends StatefulWidget {
  const CreateQuiz({Key? key}) : super(key: key);

  @override
  _CreateQuizState createState() => _CreateQuizState();
}

// Widget to display a form to create a new quiz
class _CreateQuizState extends State<CreateQuiz> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String quizTitle = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Quiz'),
      resizeToAvoidBottomInset: false,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 20.0, horizontal: 30.0),
            child: buildTabTitle('Create New Quiz', 40),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Quiz Title',
                    ),
                    // Quiz titles cannot be empty and must be
                    // below 40 characters
                    validator: (String? value) {
                      if (value != null && value.trim() == '') {
                        return "Quiz Title cannot be empty!";
                      }
                      else if (value!.length > 40) {
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
                    child: const Text('Create Quiz'),
                    // When the Create Quiz button is tapped check whether the
                    // quiz name is valid and create a new quiz document
                    // that contains the typed name
                    // And return the user back to the EditQuizzes screen
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _database.createQuiz(quizTitle);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
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
