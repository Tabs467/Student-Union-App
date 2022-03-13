import 'package:flutter/material.dart';
import 'package:student_union_app/services/authentication.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class MonthlyLeaderboard extends StatefulWidget {
  const MonthlyLeaderboard({Key? key}) : super(key: key);

  @override
  _MonthlyLeaderboardState createState() => _MonthlyLeaderboardState();
}

class _MonthlyLeaderboardState extends State<MonthlyLeaderboard> {
  final AuthenticationService _auth = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
