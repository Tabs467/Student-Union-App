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
import 'package:student_union_app/screens/menu/menu.dart';
import 'package:student_union_app/screens/menu/menuEditor/createMenuGroup.dart';
import 'package:student_union_app/screens/menu/menuEditor/editMenuGroups.dart';
import 'package:student_union_app/screens/news/news.dart';
import 'package:student_union_app/screens/quiz/activeQuiz.dart';
import 'package:student_union_app/screens/quiz/leaderboardAuth.dart';
import 'package:student_union_app/screens/quiz/leaderboards/adminMonthlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/leaderboards/adminSemesterlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/leaderboards/adminYearlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/leaderboards/monthlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/leaderboards/semesterlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/leaderboards/yearlyLeaderboard.dart';
import 'package:student_union_app/screens/quiz/myTeam.dart';
import 'package:student_union_app/screens/quiz/quizAdminMenu.dart';
import 'package:student_union_app/screens/quiz/quizAuth.dart';
import 'package:student_union_app/screens/quiz/quizControl.dart';
import 'package:student_union_app/screens/quiz/quizEditor/createQuiz.dart';
import 'package:student_union_app/screens/quiz/quizEditor/editQuizzes.dart';
import 'package:student_union_app/screens/quiz/selectQuiz.dart';

Future<void> main() async {

  // Initialise Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Disable landscape mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Default route is to the Food/Drink Menu
  runApp(MaterialApp(
    initialRoute: '/menu',
    routes: {
      '/authentication/authenticate': (context) => const Authenticate(),
      '/authentication/forgotPassword': (context) => const ForgotPassword(),
      '/authentication/register': (context) => const Register(),
      '/authentication/signIn': (context) => const SignIn(),
      '/bandaoke/bandaokeAuth': (context) => const BandaokeAuth(),
      '/comedy/comedyNight': (context) => const ComedyNight(),
      '/comedy/comedyNightAdmin': (context) => const ComedyNightAdmin(),
      '/menu': (context) => const Menu(),
      '/menu/menuEditor/createMenuGroup': (context) => const CreateMenuGroup(),
      '/menu/menuEditor/editMenuGroups': (context) => const EditMenuGroups(),
      '/news/news': (context) => const News(),
      '/quiz/activeQuiz': (context) => const ActiveQuiz(),
      '/quiz/admin': (context) => const QuizAdmin(),
      '/quiz/leaderboards': (context) => const LeaderboardAuth(),
      '/quiz/leaderboards/adminMonthly': (context) => const AdminMonthlyLeaderboard(),
      '/quiz/leaderboards/adminSemesterly': (context) => const AdminSemesterlyLeaderboard(),
      '/quiz/leaderboards/adminYearly': (context) => const AdminYearlyLeaderboard(),
      '/quiz/leaderboards/monthly': (context) => const MonthlyLeaderboard(),
      '/quiz/leaderboards/semesterly': (context) => const SemesterlyLeaderboard(),
      '/quiz/leaderboards/yearly': (context) => const YearlyLeaderboard(),
      '/quiz/myTeam': (context) => const MyTeam(),
      '/quiz/quizAuth': (context) => const QuizAuth(),
      '/quiz/quizControl': (context) => const QuizControl(),
      '/quiz/quizEditor/createQuiz': (context) => const CreateQuiz(),
      '/quiz/quizEditor/editQuizzes': (context) => const EditQuizzes(),
      '/quiz/selectQuiz': (context) => const SelectQuiz(),
    },
  ));
}