import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/services/authentication.dart';

import '../buildTabTitle.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

// Widget to display the register screen
class _RegisterState extends State<Register> {
  final AuthenticationService _auth = AuthenticationService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String email = '';
  String password = '';
  String name = '';
  String teamName = '';
  String error = '';
  bool hidePassword = true;

  // Passwords must have at least 8 characters, one uppercase letter,
  // one lowercase letter, one number, and one special character
  bool _validatePassword(String password){
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
        appBar: buildAppBar(context, 'Login'),
        body: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTabTitle('Register', 40),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                        // Email field cannot be left empty
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return "Email can't be empty!";
                          }
                          return null;
                        },
                        // Update text field state
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Password',
                          // State to hide and show the password when the user
                          // taps the visibility icon on the text field
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color.fromRGBO(22, 66, 139, 1),
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: hidePassword,
                        // Passwords must have at least 8 characters,
                        // one uppercase letter, one lowercase letter,
                        // one number, and one special character
                        validator: (String? value) {
                          if (value != null && !_validatePassword(value)) {
                            setState(() {
                              error = 'Password must have at least 8 characters, one uppercase letter, one lowercase letter, one number, and one special character!';
                            });
                            return "Invalid Password Format";
                          }
                          return null;
                        },
                        // Update text field state
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Name',
                        ),
                        // Name cannot be empty and must be below 70 characters
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return "Name cannot be empty!";
                          }
                          else if (value!.length > 70) {
                            return "Name must be below 70 characters!";
                          }
                          return null;
                        },
                        // Update text field state
                        onChanged: (val) {
                          setState(() {
                            name = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Pub Quiz Team Name',
                        ),
                        // Team Name cannot be empty and must be below 40
                        // characters
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return "Team name cannot be empty!";
                          }
                          else if (value!.length > 40) {
                            return "Team Name must be below 40 characters!";
                          }
                          return null;
                        },
                        // Update text field state
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
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                          maximumSize: const Size(200, 50),
                          primary: const Color.fromRGBO(22, 66, 139, 1),
                        ),
                        child: const Text('Register Account'),
                        // If the form validator passes
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Attempt to register the user with the typed
                            // credentials
                            dynamic result =
                                await _auth.registerWithEmailAndPassword(
                                    email, password, name, teamName);

                            // If an invalid email format is provided (checked
                            // by Google Auth)
                            if (result == 'Invalid Email') {
                              setState(() {
                                error = 'Please supply a valid email';
                              });
                              // If an in-use email is provided
                              // (checked by Google Auth)
                            } else if (result == 'Email Already In Use') {
                              setState(() {
                                error = 'Email already in use';
                              });
                              // If the register failed for any other reason
                            } else if (result == 'Register Failed') {
                              setState(() {
                                error = 'Register Failed, Please Try Again';
                              });
                              // Otherwise if the typed details are valid and
                              // not in use
                            } else {
                              // The user has already been stored in the
                              // Google Auth and Google Firestore databases
                              // upon successful completion of the previous
                              // register function.

                              // Send an email verification email to the new
                              // user's email
                              await _auth.sendEmailVerification();

                              // Sign the user out as they must verify
                              // themselves before logging in
                              await _auth.signOut();

                              // Navigate the user to the log-in screen
                              Navigator.pushReplacementNamed(
                                  context, '/authentication/authenticate');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 40.0),
                      const Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      InkWell(
                        child: const Text(
                          "Login Here!",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 20.0,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, '/authentication/signIn');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
