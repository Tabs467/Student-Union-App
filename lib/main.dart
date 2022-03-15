import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_union_app/screens/authentication/authenticate.dart';
import 'package:student_union_app/screens/authentication/forgotPassword.dart';
import 'package:student_union_app/screens/authentication/register.dart';
import 'package:student_union_app/screens/authentication/signIn.dart';
import 'package:student_union_app/screens/bandaoke/bandaokeAuth.dart';
import 'package:student_union_app/screens/comedy/ComedyNight.dart';
import 'package:student_union_app/screens/comedy/ComedyNightAdmin.dart';
import 'package:student_union_app/screens/menu/createMenuGroup.dart';
import 'package:student_union_app/screens/menu/editMenuGroups.dart';
import 'package:student_union_app/screens/menu/menu.dart';
import 'package:student_union_app/screens/news/news.dart';
import 'package:student_union_app/screens/quiz/activeQuiz.dart';
import 'package:student_union_app/screens/quiz/admin.dart';
import 'package:student_union_app/screens/quiz/adminMonthlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/adminSemesterlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/adminYearlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/createQuiz.dart';
import 'package:student_union_app/screens/quiz/editQuizzes.dart';
import 'package:student_union_app/screens/quiz/leaderboardAuth.dart';
import 'package:student_union_app/screens/quiz/monthlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/myTeam.dart';
import 'package:student_union_app/screens/quiz/quizAuth.dart';
import 'package:student_union_app/screens/quiz/quizControl.dart';
import 'package:student_union_app/screens/quiz/selectQuiz.dart';
import 'package:student_union_app/screens/quiz/semesterlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/yearlyLeaderboard.dart';

Future<void> main() async {

  // Initialise Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Disable landscape mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Default route is to the Food/Drink Menu
  runApp(MaterialApp(
    initialRoute: '/quiz/monthly',
    routes: {
      '/menu': (context) => const Menu(),
      '/menu/createMenuGroup': (context) => const CreateMenuGroup(),
      '/menu/editMenuGroups': (context) => const EditMenuGroups(),
      '/quiz/activeQuiz': (context) => const ActiveQuiz(),
      '/quiz/admin': (context) => const QuizAdmin(),
      '/quiz/adminMonthly': (context) => const AdminMonthlyLeaderboard(),
      '/quiz/adminSemesterly': (context) => const AdminSemesterlyLeaderboard(),
      '/quiz/adminYearly': (context) => const AdminYearlyLeaderboard(),
      '/quiz/monthly': (context) => const MonthlyLeaderboard(),
      '/quiz/semesterly': (context) => const SemesterlyLeaderboard(),
      '/quiz/yearly': (context) => const YearlyLeaderboard(),
      '/quiz/admin/createQuiz': (context) => const CreateQuiz(),
      '/quiz/admin/editQuizzes': (context) => const EditQuizzes(),
      '/quiz/admin/quizControl': (context) => const QuizControl(),
      '/quiz/admin/selectQuiz': (context) => const SelectQuiz(),
      '/quiz/leaderboards': (context) => const LeaderboardAuth(),
      '/quiz/quizAuth': (context) => const QuizAuth(),
      '/quiz/myTeam': (context) => const MyTeam(),
      '/authentication/authenticate': (context) => const Authenticate(),
      '/authentication/register': (context) => const Register(),
      '/authentication/signIn': (context) => const SignIn(),
      '/authentication/forgotPassword': (context) => const ForgotPassword(),
      '/bandaoke/bandaokeAuth': (context) => const BandaokeAuth(),
      '/comedy/comedyNight': (context) => const ComedyNight(),
      '/comedy/comedyNightAdmin': (context) => const ComedyNightAdmin(),
      '/news/news': (context) => const News(),
    },
  ));
}