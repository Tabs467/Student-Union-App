import 'package:student_union_app/services/database.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:student_union_app/models/CurrentUser.dart';

// Authentication Service class to provide Google Auth data and services
// to the Views
class AuthenticationService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create CurrentUser object based on FirebaseUser object (FirebaseUser
  // does not contain email, name, teamName, wins, admin).
  CurrentUser? _userFromFirebase(User user) {
    return CurrentUser(
        uid: user.uid,
        email: 'not set',
        name: 'not set',
        teamName: 'not set',
        wins: 0,
        admin: false);
  }

  // Return whether there is a user currently logged-in
  bool userLoggedIn() {
    return _auth.currentUser != null;
  }

  // Return the UID of the currently logged in user
  String? currentUID() {
    return _auth.currentUser?.uid;
  }

  // Return the email of the currently logged in user
  String? currentEmail() {
    return _auth.currentUser?.email;
  }

  // Sign in anonymously (without an account) and return a CurrentUser
  // model object of the signed-in anonymous user
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userFromFirebase(user);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Sign in with email and password and return a CurrentUser
  // model object of the signed-in user
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      return _userFromFirebase(user);
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Register with email and password and return a CurrentUser
  // model object of the signed-in user
  Future registerWithEmailAndPassword(
      String email, String password, String name, String teamName) async {
    String returnedFuture = '';

    try {
      // Attempt to create the user in the Google Auth database
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User user = result.user!;

      // Attempt to retrieve the new Google Auth user's ID
      String? uid = _userFromFirebase(user)?.uid;

      // Create a Google Firebase entry into the Users collection of the new
      // user
      await DatabaseService().updateUser(uid!, name, teamName, 0, false);

      return _userFromFirebase(user);

      // Return the appropriate error code if registration fails
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        returnedFuture = 'Email Already In Use';
      } else if (e.code == 'invalid-email') {
        returnedFuture = 'Invalid Email';
      } else {
        returnedFuture = 'Register Failed';
      }
    }
    return returnedFuture;
  }

  // Send an email verification email to the currently logged-in user
  Future sendEmailVerification() async {
    return _auth.currentUser!.sendEmailVerification();
  }

  // Check whether the currently logged-in user's email is verified
  bool emailVerified() {
    return _auth.currentUser!.emailVerified;
  }

  // Sign out the currently logged-in user
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  // Send a password reset email to the given email
  // No matching email found error is caught by the API
  Future sendPasswordResetRequest(email) async {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
