import 'package:flutter/material.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class LeaderboardMenu extends StatefulWidget {
  const LeaderboardMenu({Key? key}) : super(key: key);

  @override
  _LeaderboardMenuState createState() => _LeaderboardMenuState();
}

// Widget to display the leaderboards menu where the user can navigate to the
// monthly, semesterly, and yearly leaderboards
class _LeaderboardMenuState extends State<LeaderboardMenu> {
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
                          image: const AssetImage('assets/leaderboards.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/quiz/monthly');
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
                          image: const AssetImage('assets/leaderboards.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/quiz/semesterly');
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
                              'assets/leaderboards.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/quiz/yearly');
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
