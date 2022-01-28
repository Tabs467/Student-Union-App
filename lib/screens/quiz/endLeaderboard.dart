import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';

class EndLeaderboard extends StatefulWidget {
  final String quizID;

  const EndLeaderboard({Key? key, required this.quizID}) : super(key: key);

  @override
  _EndLeaderboardState createState() => _EndLeaderboardState();
}

// Widget to display the end of quiz leaderboard containing each participating
// pub quiz team's name and score in descending order
class _EndLeaderboardState extends State<EndLeaderboard> {
  final AuthenticationService _auth = AuthenticationService();
  final DatabaseService _database = DatabaseService();

  late String quizID;

  // Retrieve the id of which quiz to output the scores from
  @override
  void initState() {
    quizID = widget.quizID;
    super.initState();
  }

  // Retrieve the user data to determine the team name of the given user
  _getTeamName(String uid) async {
    return await _database.getUserData(uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        // Stream returns all the Score documents for the given quiz in
        // order of descending score
        stream: FirebaseFirestore.instance
            .collection('Scores')
            .orderBy('score', descending: true)
            .where('quizID', isEqualTo: quizID)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Error message
          if (snapshot.hasError) {
            return const Text(
                'Something went wrong retrieving the leaderboard');
          }
          // If the stream has not fully returned any data yet display a
          // loading Widget
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading the leaderboard...');
          }

          return Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
            child: Column(
              children: [
                buildTabTitle("End of Quiz"),
                const SizedBox(height: 25.0),
                // Display a list of each team name and score for each team
                // that participated in the quiz in order of descending score
                ListView(
                    shrinkWrap: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      // Retrieve the user id of the Score document
                      String uid = data['userID'];

                      // FutureBuilder to display another loading Widget until
                      // _getTeamName returns the user data from the user id of
                      // the Score document
                      // This is done to discover the team name related to the
                      // Score document
                      return FutureBuilder(
                        future: _getTeamName(uid),
                        builder: (context, snapshot) {
                          // If the user data query has finished display
                          // the row on the scoreboard
                          if (snapshot.connectionState ==
                              ConnectionState.done) {

                            // Store the returned user data (returned as a
                            // CurrentUser model) inside of a CurrentUser model
                            CurrentUser returnedUser =
                                snapshot.data as CurrentUser;

                            // Use the authentication service to determine the
                            // user id of the currently logged-in user
                            String loggedInUser = _auth.currentUID()!;

                            // Build the row on the scoreboard
                            return Card(
                              // If the user in the Score record is the
                              // currently logged-in user highlight the row
                              color: (loggedInUser == returnedUser.uid)
                                  ? Colors.pink
                                  : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                // Display the team name of the user related
                                // to the score document and display the score
                                // from the score document
                                child: Text(
                                  returnedUser.teamName +
                                      " - " +
                                      data['score'].toString(),
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                            // Whilst the user data query is still being
                            // carried out display a loading Widget
                          } else {
                            return const Text('Loading...');
                          }
                        },
                      );
                    }).toList()),
                const SizedBox(height: 25.0),
                // Button to return back to the Pub Quiz Main Menu
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    maximumSize: const Size(200, 50),
                    primary: const Color.fromRGBO(22, 66, 139, 1),
                  ),
                  child: const Text('Return'),
                  onPressed: () async {
                    Navigator.pushReplacementNamed(context, '/quiz/quizAuth');
                  },
                ),
              ],
            ),
          );
        });
  }
}
