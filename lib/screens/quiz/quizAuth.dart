import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/screens/quiz/quizMainMenu.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';
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
          return Scaffold(
            backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
            appBar: buildAppBar(context, 'Quiz'),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  child: buildTabTitle('Pub Quiz', 40),
                ),
                const SizedBox(height: 20.0),
                const SpinKitRing(
                  color: Colors.white,
                  size: 150.0,
                ),
              ],
            ),
          );
        }
      });
}
