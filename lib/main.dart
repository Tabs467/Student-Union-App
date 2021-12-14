import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/quiz/activeQuiz.dart';
import 'package:student_union_app/screens/quiz/admin.dart';
import 'package:student_union_app/screens/menu/menu.dart';
import 'package:student_union_app/screens/menu/mains.dart';
import 'package:student_union_app/screens/quiz/quiz.dart';
import 'package:student_union_app/screens/quiz/quizControl.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: '/menu',
    routes: {
      '/menu': (context) => Menu(),
      '/quiz': (context) => Quiz(),
      '/quiz/activeQuiz': (context) => ActiveQuiz(),
      '/quiz/admin': (context) => QuizAdmin(),
      '/quiz/admin/quizControl': (context) => QuizControl(),
      '/menu/mains': (context) => Mains(),
    },
  ));
}