import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';

class AnonQuizMainMenu extends StatefulWidget {
  const AnonQuizMainMenu({Key? key}) : super(key: key);

  @override
  _AnonQuizMainMenuState createState() => _AnonQuizMainMenuState();
}

bool noActiveQuiz = true;

// Widget to display the Quiz Main Menu screen for user's that are not
// logged-in - so some buttons on the screen lead to the login page rather than
// the active quiz page or the 'My Team' page.
class _AnonQuizMainMenuState extends State<AnonQuizMainMenu> {
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
                  child: buildTabTitle('Pub Quiz'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 3.0),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Card(
                        margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                        child: Ink.image(
                          image: const AssetImage('assets/sign_up_to_play.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/authentication/authenticate');
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
                                //Navigator.pushNamed(
                                //context, '/quiz/leaderboards');
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
                              'assets/sign_up_to_keep_track_of_your_team.png'),
                          fit: BoxFit.fill,
                          child: InkWell(
                              splashColor: Colors.black.withOpacity(.3),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/authentication/authenticate');
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
