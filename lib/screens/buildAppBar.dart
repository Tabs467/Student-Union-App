import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context, String selectedTab) {
  return AppBar(
    backgroundColor: Color.fromRGBO(22, 66, 139, 1),
    //title: Image.asset('assets/US_SU_Logo.jpg', fit: BoxFit.fitWidth),
    actions: <Widget>[
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              'assets/US_SU_Logo.jpg',
              fit: BoxFit.contain,
              height: 100,
            ),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.fastfood_rounded),
                  tooltip: 'Food/Drink Menu',
                  color: (selectedTab == 'Menu') ? Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.quiz_rounded),
                  tooltip: 'Pub Quiz',
                  color: (selectedTab == 'Quiz') ? Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/quiz');
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.mic_external_on_rounded),
                  tooltip: 'Bandaoke',
                  color: (selectedTab == 'Bandaoke') ? Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.emoji_emotions_rounded),
                  tooltip: 'Comedy Night',
                  color: (selectedTab == 'Comedy') ? Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.campaign_rounded),
                  tooltip: 'News',
                  color: (selectedTab == 'News') ? Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.person_rounded),
                  tooltip: 'Login/Register',
                  color: (selectedTab == 'Login') ? Color.fromRGBO(244, 175, 20, 1) : Colors.white,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/menu');
                  },
                )
              ],
            ),
          ],
        ),
      ),
    ]
  );
}