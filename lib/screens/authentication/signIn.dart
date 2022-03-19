import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/authentication.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

// Widget to display the sign-in screen
class _SignInState extends State<SignIn> {
  final AuthenticationService _auth = AuthenticationService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String email = '';
  String password = '';
  String error = '';
  bool hidePassword = true;

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
                buildTabTitle('Sign in', 40),
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
                            return "Email field left empty!";
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
                        // Password field cannot be left empty
                        validator: (String? value) {
                          if (value != null && value.trim() == '') {
                            return "Password field left empty!";
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
                        child: const Text('Sign in'),
                        onPressed: () async {
                          // If the form validator passes
                          if (_formKey.currentState!.validate()) {
                            // Attempt to sign the user in with the typed
                            // credentials
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);
                            // If the result is null they have typed
                            // incorrect credentials
                            if (result == null) {
                              setState(() {
                                error = 'Invalid Email or Password';
                              });
                              // If they have typed the correct credentials
                              // and they have verified their email address
                              // Leave the user signed-in and navigate them to
                              // the Food/Drink Menu screen
                            } else {
                              if (_auth.emailVerified()) {
                                Navigator.pushReplacementNamed(
                                    context, '/menu');
                                // Otherwise if the user has not verified their
                                // email address
                                // Send another verification email, sign
                                // the user out and notify them that they are
                                // not verified
                              } else {
                                await _auth.sendEmailVerification();
                                await _auth.signOut();
                                setState(() {
                                  error =
                                      "Email not verified! Check your inbox for a verification email!";
                                });
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20.0),
                      InkWell(
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 15.0,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, '/authentication/forgotPassword');
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
