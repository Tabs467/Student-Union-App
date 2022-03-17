import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/models/LeaderboardEntry.dart';
import 'package:student_union_app/models/YearlyLeaderboardDoc.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class YearlyLeaderboard extends StatefulWidget {
  const YearlyLeaderboard({Key? key}) : super(key: key);

  @override
  _YearlyLeaderboardState createState() => _YearlyLeaderboardState();
}

// Widget to display the Pub Quiz yearly leaderboards as scrollable lists
// In order of descending total wins
// Top three places are highlighted gold, silver, and bronze
// Prize for winning is displayed at the top
// Navigation floating action buttons can be used to navigate between each
// season
class _YearlyLeaderboardState extends State<YearlyLeaderboard> {
  final AuthenticationService _auth = AuthenticationService();
  final DatabaseService _database = DatabaseService();

  // The latest season state
  int seasonNumber = 1;

  // The difference that will be negated off seasonNumber to navigate to
  // previous seasons
  // Since the latest season is displayed first
  // So if for instance, the back floating action button is tapped to display
  // the previous season, +1 will be added to this difference
  int selectedSeasonDifference = 1;

  // Highest total wins on the leaderboard state
  int firstHighestWins = 0;

  // List of returned total wins in the leaderboard
  late List<int> winsList;

  // Retrieve the user data to determine the team name of the given user
  _getTeamName(String uid) async {
    return await _database.getUserData(uid);
  }

  // Retrieve the latest season number
  Future _retrieveCurrentYearlySeason() async {
    seasonNumber = await _database.retrieveCurrentYearlySeason();
  }

  @override
  Widget build(BuildContext context) {

    // FutureBuilder to retrieve the latest season number before the leaderboard
    // is built
    // Since the latest season is displayed first
    return FutureBuilder(
        future: _retrieveCurrentYearlySeason(),
        builder: (context, snapshot) {

          // When the latest season number has been returned
          if (snapshot.connectionState == ConnectionState.done) {

            // Build the leaderboard
            return Scaffold(
                backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                appBar: buildAppBar(context, 'Quiz'),
                body: Column(
                  children: [

                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                      child: buildTabTitle('Yearly Leaderboard', 30),
                    ),


                    StreamBuilder<QuerySnapshot>(
                      // Set the stream to listen to the singleton yearly
                      // leaderboard document
                      // So that the current season's prize can be retrieved
                        stream: _database.getYearlyLeaderboardDoc(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text(
                                'Something went wrong retrieving the leaderboard doc');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SpinKitRing(
                              color: Colors.white,
                              size: 50.0,
                            );
                          }

                          return Padding(
                            padding:
                            const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                            child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;

                                  YearlyLeaderboardDoc yearlyDoc = _database
                                      .yearlyLeaderboardDocFromSnapshot(data);

                                  // Update the current season variable each time the
                                  // current season changes in the database
                                  seasonNumber = yearlyDoc.currentSeason!;


                                  // Build the card containing the prize description
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 3.0, horizontal: 0),
                                    child: ClipRRect(
                                      child: Card(
                                        shape: const Border(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  22, 66, 139, 1),
                                              width: 5),
                                        ),
                                        elevation: 5,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 5.0),
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 5.0,
                                                  horizontal: 5.0),
                                              child: Center(
                                                child: Text(
                                                  "Prize: " +
                                                      yearlyDoc.prizes![
                                                      seasonNumber -
                                                          selectedSeasonDifference],
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList()),
                          );
                        }),


                    const SizedBox(height: 15.0),


                    StreamBuilder<QuerySnapshot>(
                      // Set the stream to listen to the yearly leaderboard
                      // entries documents
                        stream: _database.getYearlyScores(
                            seasonNumber - selectedSeasonDifference + 1),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text(
                                'Something went wrong retrieving the entries');
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SpinKitRing(
                              color: Colors.white,
                              size: 50.0,
                            );
                          }


                          // Determine the three highest total wins

                          // Set the list of wins to a List filled with 0s that is the
                          // same length as the number of returned leaderboard documents
                          // -1 (to account for the singleton doc in the collection)
                          winsList = List<int>.filled(
                              snapshot.data!.docs.length, 0,
                              growable: true);

                          // For each returned leaderboard entry document
                          for (var winsIndex = 0;
                          winsIndex < (snapshot.data!.docs.length);
                          winsIndex++) {
                            // If the totalWins field in the entry document is not null
                            if (snapshot.data!.docs[winsIndex]['totalWins'] !=
                                null) {
                              // Add the totalWins field's value to the List of wins
                              winsList[winsIndex] =
                              snapshot.data!.docs[winsIndex]['totalWins'];
                            }
                          }

                          // Determine the values of the three highest total wins so that the
                          // leaderboard rows that contain them can be coloured gold, silver,
                          // or bronze later in the ListView Widget
                          firstHighestWins = 0;
                          int secondHighestWins = 0;
                          int thirdHighestWins = 0;
                          for (int wins in winsList) {
                            if (wins >= firstHighestWins) {
                              firstHighestWins = wins;
                            } else if (wins >= secondHighestWins) {
                              secondHighestWins = wins;
                            } else if (wins >= thirdHighestWins) {
                              thirdHighestWins = wins;
                            }
                          }

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 0.0, 20.0, 0.0),
                              child: ListView(
                                  shrinkWrap: true,
                                  children: snapshot.data!.docs
                                      .map((DocumentSnapshot document) {
                                    Map<String, dynamic> data = document.data()!
                                    as Map<String, dynamic>;

                                    // Use the database to create a
                                    // LeaderboardEntry model from the snapshot
                                    LeaderboardEntry leaderboardEntry =
                                    _database
                                        .leaderboardEntryFromSnapshot(data);


                                    // Format total wins as plural or singular
                                    // depending its value
                                    String formattedTotalWins
                                    = leaderboardEntry.totalWins.toString();

                                    if (leaderboardEntry.totalWins == 1) {
                                      formattedTotalWins += " Win\n";
                                    }
                                    else {
                                      formattedTotalWins += " Wins\n";
                                    }


                                    // Do not display the singleton yearly
                                    // leaderboard doc in the list
                                    // 'OrAMZAbg8wi3UTUgcYth' is the ID of this
                                    // document
                                    if (leaderboardEntry.id !=
                                        'OrAMZAbg8wi3UTUgcYth') {
                                      String uid = leaderboardEntry.userID!;

                                      // FutureBuilder to display another loading Widget until
                                      // _getTeamName returns the user data from the user id of
                                      // the YearlyLeaderboardEntry document
                                      // This is done to discover the team name related to the
                                      // YearlyLeaderboardEntry document
                                      return FutureBuilder(
                                        future: _getTeamName(uid),
                                        builder: (context, snapshot) {
                                          // If the user data query has finished, display
                                          // the row on the leaderboard
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {

                                            // Store the returned user data (returned as a
                                            // CurrentUser model) inside of a CurrentUser model
                                            CurrentUser returnedUser =
                                            snapshot.data as CurrentUser;

                                            // Use the authentication service to determine the
                                            // user id of the currently logged-in user
                                            // And then determine whether this row is
                                            // outputting the logged-in user's position.
                                            // Only if a user is logged in
                                            bool loggedInUser = false;
                                            if (_auth.userLoggedIn()) {
                                              loggedInUser =
                                              (returnedUser.uid ==
                                                  _auth.currentUID()!);
                                            }

                                            // Build the row on the leaderboard
                                            return Card(

                                              // Shared and non-shared first, second and third
                                              // place rows are coloured gold, silver, or
                                              // bronze
                                              // If the currently logged-in user's total wins is not
                                              // in the top three it will be coloured pink
                                              color: (leaderboardEntry
                                                  .totalWins! ==
                                                  firstHighestWins)
                                                  ? Colors.yellow
                                                  : (leaderboardEntry
                                                  .totalWins! ==
                                                  secondHighestWins)
                                                  ? Colors.blueGrey[300]
                                                  : (leaderboardEntry
                                                  .totalWins! ==
                                                  thirdHighestWins)
                                                  ? Colors
                                                  .deepOrangeAccent[200]
                                                  : (loggedInUser)
                                                  ? Colors.pink
                                                  : Colors.white,
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(8.0),

                                                // Display the team name of the user related
                                                // to the leaderboard entry document and display
                                                // its total wins and total points
                                                child: Center(
                                                  child: Text(
                                                    returnedUser.teamName +
                                                        " - " +
                                                        formattedTotalWins +
                                                        leaderboardEntry
                                                            .totalPoints
                                                            .toString() +
                                                        " Points",
                                                    style: const TextStyle(
                                                      fontStyle:
                                                      FontStyle.italic,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );


                                            // Whilst the user data query is still being
                                            // carried out display a loading Widget
                                          } else {
                                            return const SpinKitRing(
                                              color: Colors.white,
                                              size: 50.0,
                                            );
                                          }
                                        },
                                      );
                                    }

                                    // Display an empty container for singleton document
                                    // in the collection, instead of a leaderboard row
                                    else {
                                      return Container();
                                    }
                                  }).toList()),
                            ),
                          );
                        }),


                    const SizedBox(height: 15.0),
                  ],
                ),



                // Forward and back floating action buttons for navigation
                // between seasons
                floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

                floatingActionButton: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        // If the latest season is currently selected and there is more
                        // than one season, only display the back button
                        children: ((selectedSeasonDifference == 1) &&
                            (seasonNumber > 1))
                            ? <Widget>[
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                selectedSeasonDifference++;
                              });
                            },
                            child: const Icon(Icons.arrow_back_rounded),
                            backgroundColor:
                            const Color.fromRGBO(22, 66, 139, 1),
                          ),
                          Opacity(
                            opacity: 0,
                            child: FloatingActionButton(
                              onPressed: () {},
                              child:
                              const Icon(Icons.arrow_forward_rounded),
                              backgroundColor:
                              const Color.fromRGBO(22, 66, 139, 1),
                            ),
                          ),
                        ]

                        // If the first season is currently selected and there
                        // is more than one season, only display a next button
                            : ((selectedSeasonDifference == seasonNumber) &&
                            (seasonNumber != 1))
                            ? <Widget>[
                          Opacity(
                            opacity: 0,
                            child: FloatingActionButton(
                              onPressed: () {},
                              child: const Icon(
                                  Icons.arrow_back_rounded),
                              backgroundColor: const Color.fromRGBO(
                                  22, 66, 139, 1),
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                selectedSeasonDifference--;
                              });
                            },
                            child: const Icon(
                                Icons.arrow_forward_rounded),
                            backgroundColor:
                            const Color.fromRGBO(22, 66, 139, 1),
                          ),
                        ]

                        // If there is only one season, do not display either button
                            : (seasonNumber == 1)
                            ? <Widget>[
                          Opacity(
                            opacity: 0,
                            child: FloatingActionButton(
                              onPressed: () {},
                              child: const Icon(
                                  Icons.arrow_back_rounded),
                              backgroundColor:
                              const Color.fromRGBO(
                                  22, 66, 139, 1),
                            ),
                          ),
                          Opacity(
                            opacity: 0,
                            child: FloatingActionButton(
                              onPressed: () {},
                              child: const Icon(
                                  Icons.arrow_forward_rounded),
                              backgroundColor:
                              const Color.fromRGBO(
                                  22, 66, 139, 1),
                            ),
                          ),
                        ]

                        // Otherwise display both buttons
                            : <Widget>[
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                selectedSeasonDifference++;
                              });
                            },
                            child: const Icon(
                                Icons.arrow_back_rounded),
                            backgroundColor: const Color.fromRGBO(
                                22, 66, 139, 1),
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                selectedSeasonDifference--;
                              });
                            },
                            child: const Icon(
                                Icons.arrow_forward_rounded),
                            backgroundColor: const Color.fromRGBO(
                                22, 66, 139, 1),
                          ),
                        ])));

            // Otherwise, display a loading Widget whilst the latest season
            // number is being returned
          } else {
            return Scaffold(
              backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
              appBar: buildAppBar(context, 'Quiz'),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50.0),
                    child: buildTabTitle('Yearly Leaderboard', 30),
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
}
