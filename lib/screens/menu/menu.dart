import 'package:flutter/material.dart';
import 'package:student_union_app/Models/MenuGroup.dart';
import 'package:student_union_app/Models/MenuSubGroup.dart';
import 'package:student_union_app/Models/MenuItem.dart';


class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  // Temporarily static menu groups, subgroups and items
  List<MenuItem> burgers = [
    MenuItem(name: 'Cheeseburger', price: '£6'),
    MenuItem(name: 'Veggie Burger', price: '£6'),
    MenuItem(name: 'Bacon Cheeseburger', price: '£7'),
  ];
  List<MenuItem> pizzas = [
    MenuItem(name: 'Cheese Pizza', price: '£4'),
    MenuItem(name: 'Pepperoni Pizza', price: '£6'),
    MenuItem(name: 'Ham and Mushroom Pizza', price: '£6.50'),
  ];
  List<MenuItem> softDrinks = [
    MenuItem(name: 'Coke', price: '£2'),
    MenuItem(name: 'Lemonade', price: '£2'),
    MenuItem(name: 'Orange Soda', price: '£2.50'),
  ];
  List<MenuItem> juices = [
    MenuItem(name: 'Orange Juice', price: '£3'),
    MenuItem(name: 'Apple Juice', price: '£3'),
    MenuItem(name: 'Tropical Juice', price: '£3.50'),
  ];

  //List<MenuSubGroup> mainsSubMenuGroups = [
    //MenuSubGroup(name: 'Burgers', menuItems: burgers),
    //MenuSubGroup(name: 'Pizzas', menuItems: pizzas),
  //];
  //List<MenuSubGroup> drinksSubMenuGroups = [
    //MenuSubGroup(name: 'Soft Drinks', menuItems: softDrinks),
    //MenuSubGroup(name: 'Juices', menuItems: juices),
  //];


  //List<MenuGroup> menuGroups = [
    //MenuGroup(name: 'Mains', menuSubGroups: mainsSubMenuGroups),
    //MenuGroup(name: 'Drinks', menuSubGroups: drinksSubMenuGroups)
  //];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 175, 20, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(22, 66, 139, 1),
        //title: Image.asset('assets/US_SU_Logo.jpg', fit: BoxFit.fitWidth),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/US_SU_Logo.jpg',
              fit: BoxFit.contain,
              height:70,
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Food/Drink',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),


        actions: <Widget>[

          IconButton(
            icon: const Icon(Icons.fastfood_rounded),
            tooltip: 'Food/Drink Menu',
            color: Color.fromRGBO(244, 175, 20, 1),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.quiz_rounded),
            tooltip: 'Pub Quiz',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/quiz');
            },
          ),

          IconButton(
            icon: const Icon(Icons.mic_external_on_rounded),
            tooltip: 'Bandaoke',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.emoji_emotions_rounded),
            tooltip: 'Comedy Night',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.campaign_rounded),
            tooltip: 'News',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          ),

          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Login/Register',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu');
            },
          )
        ],
      ),

      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/menu/mains');
            },
            child: Container(
              height: 200,
              child: Card(
                margin: EdgeInsets.all(16.0),
                child: Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                        children: const [
                          Text(
                              'Mains',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                          ),
                        ]
                    ),
                    Image.asset(
                      'assets/Burgers.jpg',
                      fit: BoxFit.contain,
                      height:70,
                    ),
                  ],
                )
              ),
            ),
          )
        ]
      ),

    );
  }
}


