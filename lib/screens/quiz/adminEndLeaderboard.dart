import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';

class AdminEndLeaderboard extends StatefulWidget {
  final String quizID;

  const AdminEndLeaderboard({Key? key, required this.quizID}) : super(key: key);

  @override
  _AdminEndLeaderboardState createState() => _AdminEndLeaderboardState();
}

// Widget to display the end of quiz leaderboard containing each participating
// pub quiz team's name and score in descending order

// Along with an End Quiz button that will end the quiz

// Shared and non-shared first, second and third place rows are coloured gold,
// silver, or bronze
// If the currently logged-in user's score is not in the top three it will be
// coloured pink
class _AdminEndLeaderboardState extends State<AdminEndLeaderboard> {
  final AuthenticationService _auth = AuthenticationService();
  final DatabaseService _database = DatabaseService();

  late String quizID;

  // List of returned scores in the scoreboard
  late List<int> scoreList;

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

          // Set the list of scores to a List filled with 0s that is the
          // same length as the number of returned Score documents
          scoreList =
              List<int>.filled(snapshot.data!.docs.length, 0, growable: true);

          // For each returned Score document
          for (var scoreIndex = 0;
              scoreIndex < snapshot.data!.docs.length;
              scoreIndex++) {
            // If the score field in the Score document is not null
            if (snapshot.data!.docs[scoreIndex]['score'] != null) {
              // Add the score field's value to the List of scores
              scoreList[scoreIndex] = snapshot.data!.docs[scoreIndex]['score'];
            }
          }

          // Determine the values of the three highest scores so that the
          // scoreboard rows that contain them can be coloured gold, silver,
          // or bronze later in the ListView Widget
          int firstHighestScore = 0;
          int secondHighestScore = 0;
          int thirdHighestScore = 0;
          for (int score in scoreList) {
            if (score > firstHighestScore) {
              thirdHighestScore = secondHighestScore;
              secondHighestScore = firstHighestScore;
              firstHighestScore = score;
            } else if (score > secondHighestScore) {
              thirdHighestScore = secondHighestScore;
              secondHighestScore = score;
            } else if (score > thirdHighestScore) {
              thirdHighestScore = score;
            }
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
                Expanded(
                  child: RawScrollbar(
                    isAlwaysShown: true,
                    thumbColor: const Color.fromRGBO(22, 66, 139, 1),
                    //radius: Radius.circular(20),
                    thickness: 3.0,

                    child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
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
                              // If the user data query has finished, display
                              // the row on the scoreboard
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                // Store the returned user data (returned as a
                                // CurrentUser model) inside of a CurrentUser model
                                CurrentUser returnedUser =
                                    snapshot.data as CurrentUser;

                                // Use the authentication service to determine the
                                // user id of the currently logged-in user
                                // And then determine whether this row is
                                // outputting the logged-in user's score.
                                bool loggedInUser =
                                    (returnedUser.uid == _auth.currentUID()!);

                                // Build the row on the scoreboard
                                return Card(
                                  // Shared and non-shared first, second and third
                                  // place rows are coloured gold, silver, or
                                  // bronze
                                  // If the currently logged-in user's score is not
                                  // in the top three it will be coloured pink
                                  color: (data['score'] == firstHighestScore)
                                      ? Colors.yellow
                                      : (data['score'] == secondHighestScore)
                                          ? Colors.blueGrey
                                          : (data['score'] == thirdHighestScore)
                                              ? Colors.deepOrangeAccent
                                              : (loggedInUser)
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
                  ),
                ),
                const SizedBox(height: 25.0),
                // Button to end the quiz
                SizedBox(
                  height: 70,
                  child: Card(
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: InkWell(
                        // When tapped call the function to end the
                        // quiz
                        onTap: () {
                          DatabaseService().endQuiz(quizID);
                          Navigator.pushReplacementNamed(context, '/quiz/admin');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'End Quiz',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ]),
                          ],
                        ),
                      )),
                ),
                // Button to return back to the Pub Quiz Admin Menu
                SizedBox(
                  height: 70,
                  child: Card(
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: InkWell(
                        // When tapped call the function to end the
                        // quiz
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/quiz/admin');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Return',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                ]),
                          ],
                        ),
                      )),
                )
              ],
            ),
          );
        });
  }
}
