import 'package:flutter/material.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class AdminLeaderboardMenu extends StatefulWidget {
  const AdminLeaderboardMenu({Key? key}) : super(key: key);

  @override
  _AdminLeaderboardMenuState createState() => _AdminLeaderboardMenuState();
}

// Widget to display the admin leaderboards menu where the user can navigate to
// the admin versions of the monthly, semesterly, and yearly leaderboards
class _AdminLeaderboardMenuState extends State<AdminLeaderboardMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
        appBar: buildAppBar(context, 'Quiz'),
        body: RawScrollbar(
          isAlwaysShown: true,
          thumbColor: const Color.fromRGBO(22, 66, 139, 1),
          thickness: 7.5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  child: buildTabTitle('Leaderboards', 40),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 3.0),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Card(
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: Ink.image(
                          image: const AssetImage('assets/monthly.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/quiz/adminMonthly');
                              }),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 3.0),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Card(
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: Ink.image(
                          image: const AssetImage('assets/semesterly.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                context, '/quiz/adminSemesterly');
                              }),
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 3.0),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Card(
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: Ink.image(
                          image: const AssetImage(
                              'assets/yearly.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/quiz/adminYearly');
                              }),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
