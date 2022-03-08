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

          return Scaffold(
            backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
            appBar: buildAppBar(context, 'Quiz'),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
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
                              if (value != null && value.isEmpty) {
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
                          const SizedBox(height: 20.0),
                          // Pub Quiz Wins field cannot be edited
                          TextFormField(
                            initialValue: "Pub Quiz Wins: " +
                                returnedUser.wins.toString(),
                            enabled: false,
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





