import 'package:flutter/material.dart';
import 'package:student_union_app/screens/quiz/quizMainMenu.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';
import 'adminQuizMainMenu.dart';
import 'anonQuizMainMenu.dart';

class QuizAuth extends StatefulWidget {
  const QuizAuth({Key? key}) : super(key: key);

  @override
  _QuizAuthState createState() => _QuizAuthState();
}

// Widget that either displays the Pub Quiz main menu with or without the
// admin controls floating action button depending on whether there is a
// currently logged-in admin account
class _QuizAuthState extends State<QuizAuth> {
  final AuthenticationService _auth = AuthenticationService();
  final DatabaseService _database = DatabaseService();

  // This Widget uses a FutureBuilder so that a loading Widget can be displayed
  // whilst the logged-in user's data is being retrieved asynchronously.
  // Once retrieved, the appropriate version of the Quiz Main Menu page is
  // displayed.
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
      // Rebuilt when the asynchronous function determines whether there is a
      // currently logged-in admin
      future: _database.userAdmin(),
      builder: (context, AsyncSnapshot<bool> snapshot) {

        // If the asynchronous function has fully completed
        if (snapshot.hasData) {
          // If the logged-in user is an admin
          if (snapshot.data == true) {
            // Display the admin floating action button on the Quiz Main Menu
            return const AdminQuizMainMenu();
          }
          // Otherwise do not display the admin floating action button on the
          // Quiz Main Menu
          else {
            // Return a Quiz Main Menu Widget with buttons specific to whether
            // the user is logged-in or not.
            // Anonymous users will not be able to join the active quiz or
            // view the 'My Team' page - and the buttons on the page will lead
            // to the login page.
            if (_auth.userLoggedIn()) {
              return const QuizMainMenu();
            }
            else {
              return const AnonQuizMainMenu();
            }
          }
        }
        // Return a loading widget whilst the asynchronous function takes
        // time to complete
        else {
          return const Text('Loading...');
        }
      });
}
