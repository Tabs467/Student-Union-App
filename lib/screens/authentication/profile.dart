import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

// Widget to display the logged-in user's profile information and update name
// information form
// The sign-out button and reset password button is also displayed, along with
// a button to navigate to the MyTeam Widget for more detailed Pub Quiz Team
// information
class _ProfileState extends State<Profile> {
  final AuthenticationService _auth = AuthenticationService();
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
  String email = '';
  String name = '';
  String teamName = '';
  String error = '';

  // This Widget uses a FutureBuilder so that a loading Widget can be displayed
  // whilst the logged-in user's data is being retrieved asynchronously.
  // Once retrieved, the user's information on the profile page is displayed.
  @override
  Widget build(BuildContext context) => FutureBuilder(
      // Rebuilt when currentUser is updated
      // (when the user details are returned)
      future: currentUser,
      builder: (context, snapshot) {
        // If the user's details are fully returned build the profile page
        if (snapshot.connectionState == ConnectionState.done) {
          CurrentUser returnedUser = snapshot.data as CurrentUser;

          // Initially, update the text field state with the retrieved data
          if (name == '') {
            name = returnedUser.name;
          }
          if (teamName == '') {
            teamName = returnedUser.teamName;
          }
          if (email == '') {
            email = returnedUser.email;
          }

          return Scaffold(
            backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
            appBar: buildAppBar(context, 'Login'),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0),
                child: Column(
                  children: [
                    buildTabTitle('Profile', 40),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20.0),
                          // Email field cannot be edited
                          TextFormField(
                            initialValue: returnedUser.email.toString(),
                            enabled: false,
                          ),
                          const SizedBox(height: 20.0),
                          // Name can be retyped to update the Name text
                          // field state
                          TextFormField(
                            initialValue: returnedUser.name,
                            decoration: const InputDecoration(
                              hintText: 'Name',
                            ),
                            validator: (String? value) {
                              if (value != null && value.trim() == '') {
                                return "Name cannot be empty!";
                              }
                              else if (value!.length > 70) {
                                return "Name must be below 70 characters!";
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {
                                name = val;
                              });
                            },
                          ),
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
                            child: const Text('Update Name Details'),
                            // Update the user's name details in the Users
                            // collection with the stored text field state
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _database
                                    .updateUserNameDetails(name, teamName);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('View Pub Quiz Team'),
                      // Navigate the user to the MyTeam Widget
                      onPressed: () async {
                        Navigator.pushReplacementNamed(context, '/quiz/myTeam');
                      },
                    ),
                    const SizedBox(height: 25.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Send Password Reset Request'),
                      // Send a password reset request email to the currently
                      // logged-in user's email
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _auth.sendPasswordResetRequest(email);
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 25.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Sign out'),
                      // Sign the user out and navigate back to the Food/Drink
                      // Menu screen
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.pushReplacementNamed(context, '/menu');
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
          // Return a loading widget whilst the asynchronous function takes
          // time to complete
        } else {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
            appBar: buildAppBar(context, 'Login'),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 50.0
                  ),
                  child: buildTabTitle('Profile', 40),
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
