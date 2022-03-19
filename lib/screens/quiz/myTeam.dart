import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class MyTeam extends StatefulWidget {
  const MyTeam({Key? key}) : super(key: key);

  @override
  _MyTeamState createState() => _MyTeamState();
}

// Widget to display the logged-in user's pub quiz team information and update
// team name form
// When each win card is tapped a pop-up menu will display the dates of the won
// quizzes or competitions
class _MyTeamState extends State<MyTeam> {
  final DatabaseService _database = DatabaseService();

  late Future currentUser;

  // Retrieve the logged-in user's data as soon as the Widget is loaded.
  @override
  void initState() {
    super.initState();

    currentUser = _getCurrentUser();
  }

  _getCurrentUser() async {
    return await _database.getLoggedInUserData();
  }

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String teamName = '';
  String error = '';

  // This Widget uses a FutureBuilder so that a loading Widget can be displayed
  // whilst the logged-in user's data is being retrieved asynchronously.
  // Once retrieved, the user's pub quiz team information is displayed.
  @override
  Widget build(BuildContext context) => FutureBuilder(
      // Rebuilt when currentUser is updated
      // (when the user details are returned)
      future: currentUser,
      builder: (context, snapshot) {
        // If the user's details are fully returned build the My Team page
        if (snapshot.connectionState == ConnectionState.done) {
          CurrentUser returnedUser = snapshot.data as CurrentUser;

          // Initially, update the text field state with the retrieved data
          if (teamName == '') {
            teamName = returnedUser.teamName;
          }

          // Append singular or plural depending on the number of wins
          String formattedPubQuizWins = returnedUser.wins.toString();
          if (returnedUser.wins != 1) {
            formattedPubQuizWins += " Wins";
          }
          else {
            formattedPubQuizWins += " Win";
          }

          return Scaffold(
            backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
            appBar: buildAppBar(context, 'Quiz'),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 40.0),
                child: Column(
                  children: [
                    buildTabTitle('My Team', 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20.0),
                          // Team Name can be retyped to update the
                          // Team Name text field state
                          TextFormField(
                            initialValue: returnedUser.teamName,
                            decoration: const InputDecoration(
                              hintText: 'Pub Quiz Team Name',
                            ),
                            validator: (String? value) {
                              if (value != null && value.trim() == '') {
                                return "Team name cannot be empty!";
                              }
                              else if (value!.length > 40) {
                                return "Team Name must be below 40 characters!";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {
                                teamName = val;
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
                            child: const Text('Update Team Name'),
                            // Update the user's name details in the Users
                            // collection with the stored text field state
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _database
                                    .updateUserTeamNameDetails(teamName);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    InkWell(
                      borderRadius: BorderRadius.circular(100),
                      splashColor: Colors.black,
                      // When tapped show the pop-up containing the
                      // list of pub quiz win dates
                      onTap: () {showWinsDialog(
                          context,
                          returnedUser.wins,
                          returnedUser.winDates,
                          "Pub Quiz Win Dates"
                      );},
                      child: Card(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                              formattedPubQuizWins,
                            style: const TextStyle(
                              fontSize: 45,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.black,
                              // When tapped show the pop-up containing the
                              // list of monthly win dates
                              onTap: () {showWinsDialog(
                                  context,
                                  returnedUser.monthlyWins,
                                  returnedUser.monthlyWinDates,
                                  "Monthly Win Dates"
                              );},
                              child: Card(
                                elevation: 20,
                                color: Colors.deepOrangeAccent[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text(
                                    returnedUser.monthlyWins.toString(),
                                    style: const TextStyle(
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Monthly',
                              style: TextStyle(
                                  fontSize: 17.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5.0),
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.black,
                              // When tapped show the pop-up containing the
                              // list of semesterly win dates
                              onTap: () {showWinsDialog(
                                  context,
                                  returnedUser.semesterlyWins,
                                  returnedUser.semesterlyWinDates,
                                  "Semesterly Win Dates"
                              );},
                              child: Card(
                                elevation: 20,
                                color: Colors.blueGrey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text(
                                    returnedUser.semesterlyWins.toString(),
                                    style: const TextStyle(
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Semesterly',
                              style: TextStyle(
                                  fontSize: 17.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5.0),
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(100),
                              splashColor: Colors.black,
                              // When tapped show the pop-up containing the
                              // list of yearly win dates
                              onTap: () {showWinsDialog(
                                  context,
                                  returnedUser.yearlyWins,
                                  returnedUser.yearlyWinDates,
                                  "Yearly Win Dates"
                              );},
                              child: Card(
                                elevation: 20,
                                color: Colors.yellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text(
                                    returnedUser.yearlyWins.toString(),
                                    style: const TextStyle(
                                      fontSize: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Yearly',
                              style: TextStyle(
                                  fontSize: 17.5,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    const Text(
                      'Tap each number to\nview the win dates!',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // Return a loading widget whilst the asynchronous function takes
          // time to complete
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: buildTabTitle('My Team', 40),
              ),
              const SizedBox(height: 20.0),
              const SpinKitRing(
                color: Colors.white,
                size: 50.0,
              ),
            ],
          );
        }
      });
}


// The Wins pop-up Widget displays the list of dates the user won a pub quiz or
// competition
showWinsDialog(context, winCount, winsArray, title) {
  // If the user taps "Close", close the pop-up
  Widget closeButton = TextButton(
    child: const Text("Close"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // The alert dialog box
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold
      ),
    ),
    content: ListView.builder(
        shrinkWrap: true,
        itemCount: winCount,
        itemBuilder: (BuildContext context, int arrayIndex) {

          // Convert each TimeStamp to a DateTime
          DateTime unformattedDate = DateTime.parse(
              winsArray[arrayIndex].toDate().toString()
          );

          // Format DateTime for output
          String date =
              "${unformattedDate.day.toString().padLeft(2, '0')}"
              "/${unformattedDate.month.toString().padLeft(2, '0')}"
              "/${unformattedDate.year.toString()}"
              " at ${unformattedDate.hour.toString()}"
              ":${unformattedDate.minute.toString().padLeft(2, '0')}";

          // Concatenate am or pm depending on the
          // time of day stored
          if (unformattedDate.hour <= 12) {
            date += "am";
          } else {
            date += "pm";
          }

          // Display each win date in a scrollable list
          return Column(
            children: [
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    date,
                    style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10)
            ],
          );
        }),
    actions: [
      closeButton,
    ],
  );

  // The function to build the Wins pop-up Widget
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}