import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';
import 'adminLeaderboardMenu.dart';
import 'leaderboardMenu.dart';

class LeaderboardAuth extends StatefulWidget {
  const LeaderboardAuth({Key? key}) : super(key: key);

  @override
  _LeaderboardAuthState createState() => _LeaderboardAuthState();
}

// Widget that either displays the Leaderboard menu or the Admin
// Leaderboard menu depending on whether there is a
// currently logged-in admin account
class _LeaderboardAuthState extends State<LeaderboardAuth> {
  final AuthenticationService _auth = AuthenticationService();
  final DatabaseService _database = DatabaseService();

  // This Widget uses a FutureBuilder so that a loading Widget can be displayed
  // whilst the logged-in user's data is being retrieved asynchronously.
  // Once retrieved, the appropriate version of the Leaderboard Menu Widget is
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
            // Display the Admin Leaderboard menu
            return const AdminLeaderboardMenu();
          }
          // Otherwise, return the standard Leaderboard menu
          else {
            return const LeaderboardMenu();
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
                  child: buildTabTitle('Leaderboards', 40),
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
