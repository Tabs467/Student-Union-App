import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context, String selectedTab) {
  return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color.fromRGBO(22, 66, 139, 1),
      actions: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 24.0, 0.0),
                child: Image.asset(
                  'assets/us_su_logo.jpg',
                  fit: BoxFit.contain,
                  height: 100,
                ),
              ),
              Row(
                children: [

                  // Each IconButton will either display its icon colour as white or yellow depending on whether
                  // the inputted selectedTab parameter (so the tab the user selected is highlighted yellow)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fastfood_rounded),
                        tooltip: 'Food/Drink Menu',
                        color: (selectedTab == 'Menu') ? const Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/menu');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.quiz_rounded),
                        tooltip: 'Pub Quiz',
                        color: (selectedTab == 'Quiz') ? const Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/quiz/quizAuth');
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.mic_external_on_rounded),
                        tooltip: 'Bandaoke',
                        color: (selectedTab == 'Bandaoke') ? const Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/bandaoke/bandaokeAuth');
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_rounded),
                        tooltip: 'Comedy Night',
                        color: (selectedTab == 'Comedy') ? const Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/comedy/comedyNight');
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.campaign_rounded),
                        tooltip: 'News',
                        color: (selectedTab == 'News') ? const Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/news/news');
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.person_rounded),
                        tooltip: 'Login/Register',
                        color: (selectedTab == 'Login') ? const Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/authentication/authenticate');
                        },
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ]
  );
}