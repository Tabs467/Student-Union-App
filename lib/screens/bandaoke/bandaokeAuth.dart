import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/screens/bandaoke/bandaoke.dart';
import 'package:student_union_app/screens/bandaoke/bandaokeAdmin.dart';
import 'package:student_union_app/screens/bandaoke/bandaokeAnon.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/authentication.dart';
import 'package:student_union_app/services/database.dart';

class BandaokeAuth extends StatefulWidget {
  const BandaokeAuth({Key? key}) : super(key: key);

  @override
  _BandaokeAuthState createState() => _BandaokeAuthState();
}

// Widget that either displays the Bandaoke, BandaokeAnon, or BandaokeAdmin
// Widget depending on whether the user is logged-in and whether the logged-in
// user is an admin
class _BandaokeAuthState extends State<BandaokeAuth> {
  final AuthenticationService _auth = AuthenticationService();
  final DatabaseService _database = DatabaseService();

  // This Widget uses a FutureBuilder so that a loading Widget can be displayed
  // whilst the logged-in user's data is being retrieved asynchronously.
  // Once retrieved, the appropriate version of the Bandaoke Widget is
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
            // Display the BandaokeAdmin Widget
            return const BandaokeAdmin();
          }
          // Otherwise check if the user is logged-in
          else {
            // Return a Bandaoke Widget with buttons specific to whether
            // the user is logged-in or not.
            // Anonymous users will not be able to join the queue on the
            // Bandaoke screen
            if (_auth.userLoggedIn()) {
              return const Bandaoke();
            }
            else {
              return const BandaokeAnon();
            }
          }
        }
        // Return a loading widget whilst the asynchronous function takes
        // time to complete
        else {
          return Scaffold(
            backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
            appBar: buildAppBar(context, 'Bandaoke'),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 30.0
                  ),
                  child: buildTabTitle('Bandaoke', 40),
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
