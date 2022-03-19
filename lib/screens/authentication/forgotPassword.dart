import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/services/authentication.dart';

import '../buildTabTitle.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

// Widget to display the forgot password screen where the user can type in
// their account's email to send a forgot password email to regain access
// to their account.
class _ForgotPasswordState extends State<ForgotPassword> {
  final AuthenticationService _auth = AuthenticationService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String email = '';
  String error = '';

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
                buildTabTitle('Password Reset', 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                        // Email field cannot be left empty
                        validator: (String? value) {
                          if (value != null && value.trim() == '') {
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
                      const SizedBox(height: 12.0),
                      // The error text below the form
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
                        child: const Text('Send Password Reset Request'),
                        onPressed: () async {
                          // If the form input is valid send the password reset
                          // request email to the typed in email address
                          // And navigate the user to the sign-in page
                          if (_formKey.currentState!.validate()) {
                            _auth.sendPasswordResetRequest(email);
                            Navigator.pushReplacementNamed(
                                context, '/authentication/authenticate');
                          }
                        },
                      ),
                      const SizedBox(height: 40.0),
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      InkWell(
                        child: const Text(
                          "Register an Account",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 20.0,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, '/authentication/register');
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
