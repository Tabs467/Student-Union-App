import 'package:flutter/material.dart';
import 'package:student_union_app/screens/authentication/profile.dart';
import 'package:student_union_app/services/authentication.dart';
import 'signIn.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

// Widget that either displays the profile page or the sign-in page depending
// on whether the user is logged-in
class _AuthenticateState extends State<Authenticate> {
  final AuthenticationService _auth = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return (_auth.userLoggedIn()) ? const Profile() : const SignIn();
  }
}
