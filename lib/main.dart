import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/authentication/authenticate.dart';
import 'package:student_union_app/screens/authentication/forgotPassword.dart';
import 'package:student_union_app/screens/authentication/register.dart';
import 'package:student_union_app/screens/authentication/signIn.dart';
import 'package:student_union_app/screens/menu/menu.dart';
import 'package:student_union_app/screens/quiz/activeQuiz.dart';
import 'package:student_union_app/screens/quiz/admin.dart';
import 'package:student_union_app/screens/quiz/quizAuth.dart';
import 'package:student_union_app/screens/quiz/quizControl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Default route is to the Food/Drink Menu
  runApp(MaterialApp(
    initialRoute: '/menu',
    routes: {
      '/menu': (context) => const Menu(),
      '/quiz/quizAuth': (context) => const QuizAuth(),
      '/quiz/activeQuiz': (context) => const ActiveQuiz(),
      '/quiz/admin': (context) => const QuizAdmin(),
      '/quiz/admin/quizControl': (context) => const QuizControl(),
      '/authentication/authenticate': (context) => const Authenticate(),
      '/authentication/register': (context) => const Register(),
      '/authentication/signIn': (context) => const SignIn(),
      '/authentication/forgotPassword': (context) => const ForgotPassword(),
    },
  ));
}