import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/menu/menu.dart';
import 'package:student_union_app/screens/menu/mains.dart';
import 'package:student_union_app/screens/quiz/quiz.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: '/menu',
    routes: {
      '/menu': (context) => Menu(),
      '/quiz': (context) => Quiz(),
      '/menu/mains': (context) => Mains(),
    },
  ));
}