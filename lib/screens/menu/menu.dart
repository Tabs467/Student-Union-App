import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

// Widget to display the food and drink menu screen
class _MenuState extends State<Menu> {
  final DatabaseService _database = DatabaseService();

  // Default selected menu category state
  bool selectedMenuGroupIDSet = false;
  String selectedMenuGroupID = '';

  bool _isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        // Rebuilt when the asynchronous function determines whether there is a
        // currently logged-in admin
        future: _database.userAdmin(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          // If the asynchronous function has fully completed
          if (snapshot.hasData) {
            // If the logged-in user is an admin
            if (snapshot.data == true) {
              // Mark the logged-in user as an admin (for use in deciding
              // to display the admin floating action button)
              _isAdmin = true;
            }

            return Scaffold(
                backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                appBar: buildAppBar(context, 'Menu'),

                // Set up the stream that retrieves and listens to the food/drink menu groups
                // that appear in the top horizontal scrolling menu.
                body: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('MenuGroup')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                            'Something went wrong retrieving the menu groups');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 10.0),
                              child: buildTabTitle('Food/Drink Menu', 35),
                            ),
                            const SizedBox(height: 10.0),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '(v) - Vegetarian',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    Text(
                                      '(h) - Halal',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 5.0),
                                    const Text(
                                      '(ve) - Vegan',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 5.0, 0.0, 0.0
                                  ),
                                  child: Text(
                                    '(v)* - Vegetarian option available',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            const SpinKitRing(
                              color: Colors.white,
                              size: 50.0,
                            ),
                          ],
                        );
                      }

                      // Set the first menu group retrieved on the first build of
                      // the Widget tree as the initially selected menu group
                      if (snapshot.data!.docs.isNotEmpty && !selectedMenuGroupIDSet) {
                        selectedMenuGroupIDSet = true;
                        selectedMenuGroupID = snapshot.data!.docs[0]['id'];
                      }

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 10.0),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildTabTitle('Food/Drink Menu', 35),
                                const SizedBox(height: 10.0),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            '(v) - Vegetarian',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          '(h) - Halal',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.red.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          '(ve) - Vegan',
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0
                                      ),
                                      child: Text(
                                        '(v)* - Vegetarian option available',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 60.0),
                                  child: ListView(
                                      key: const PageStorageKey<String>('horizontalPosition'),
                                      scrollDirection: Axis.horizontal,
                                      children: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        Map<String, dynamic> data = document.data()!
                                            as Map<String, dynamic>;
                                        return FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Card(
                                            color: const Color.fromRGBO(
                                                22, 66, 139, 1),
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                              // If this Menu Group button is currently selected highlight its border
                                              side: BorderSide(
                                                  color: (selectedMenuGroupID ==
                                                          data['id'])
                                                      ? Colors.yellow
                                                      : Colors.black,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            child: InkWell(
                                              // When the Menu Group button is tapped it becomes the new selected Menu Group
                                              onTap: () {
                                                setState(() {
                                                  selectedMenuGroupID = data['id'];
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(9.0),
                                                child: Text(
                                                  data['name'],
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList()),
                                ),
                                const SizedBox(height: 5.0),
                                // Retrieve the Menu Sub Groups and Menu Items of the selected Menu Group
                                StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('MenuSubGroup')
                                        .where('MenuGroupID',
                                            isEqualTo: selectedMenuGroupID)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasError) {
                                        return const Text(
                                            'Something went wrong retrieving the menu groups');
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SpinKitRing(
                                          color: Colors.white,
                                          size: 50.0,
                                        );
                                      }

                                      // Display each Menu Sub Group in an expanding box which expands to show
                                      // the Menu Items contained within the Menu Sub Group
                                      return Flexible(
                                        fit: FlexFit.loose,
                                        child: ListView(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            children: snapshot.data!.docs
                                                .map((DocumentSnapshot document) {
                                          Map<String, dynamic> data = document
                                              .data()! as Map<String, dynamic>;
                                          return SizedBox(
                                              width: double.infinity,
                                              child: Card(
                                                color: const Color.fromRGBO(
                                                    255, 255, 255, 1.0),
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                      color: Colors.black,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ExpansionTile(
                                                    title: Text(
                                                      data['name'],
                                                      style: const TextStyle(
                                                        fontStyle: FontStyle.italic,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    children: <Widget>[
                                                      // For each menu item in the Menu Items array in the
                                                      // Menu Sub Group
                                                      // Display the Menu Item's information and place a
                                                      // divider under it
                                                      for (var menuItem
                                                          in data['MenuItems'])
                                                        Column(
                                                          children: [
                                                            const Divider(
                                                              thickness: 1.25,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                menuItem,
                                                                style:
                                                                    const TextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                  fontSize: 20,
                                                                  color:
                                                                      Colors.black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ));
                                        }).toList()),
                                      );
                                    }),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.0, 10.0, 0.0, 0.0
                                      ),
                                      child: Text(
                                        'Food served until 10pm',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              ]),
                        ),
                      );
                    }),
                // If the logged-in user is an admin display the admin
                // floating action button
                floatingActionButton: (_isAdmin)
                    ? SizedBox(
                        height: 200.0,
                        width: 150.0,
                        child: FittedBox(
                          child: FloatingActionButton.extended(
                            // When tapped, navigate the user to the Food/Drink
                            // menu admin Widget
                            onPressed: () {
                              Navigator.pushNamed(context, '/menu/editMenuGroups');
                            },
                            backgroundColor:
                                const Color.fromRGBO(22, 66, 139, 1),
                            label: const Text('Edit Menu'),
                            icon:
                                const Icon(Icons.admin_panel_settings_rounded),
                          ),
                        ),
                      )
                    : Container());
          }
          // Return a loading widget whilst the asynchronous function takes
          // time to complete
          else {
            return Scaffold(
              backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
              appBar: buildAppBar(context, 'Menu'),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 10.0),
                    child: buildTabTitle('Food/Drink Menu', 35),
                  ),
                  const SizedBox(height: 20.0),
                  const SpinKitRing(
                    color: Colors.white,
                    size: 150.0,
                  ),
                ],
              ),
            );
          }
        });
  }
}
