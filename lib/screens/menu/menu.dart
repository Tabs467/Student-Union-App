import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  // Default selected menu is drinks
  // Will need to update this in the future to allow users to remove the
  // drinks category.
  String selectedMenuGroupID = '2V7MRLZ9BzIjQXYfP8ug';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Menu'),

      // Set up the stream that retrieves and listens to the food/drink menu groups
      // that appear in the top horizontal scrolling menu.
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('MenuGroup').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Something went wrong retrieving the menu groups');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading Menu Groups...');
            }

            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildTabTitle('Food/Drink Menu'),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 60.0),
                    child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Card(
                              color: const Color.fromRGBO(22, 66, 139, 1),
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                // If this Menu Group button is currently selected highlight its border
                                side: BorderSide(
                                    color: (selectedMenuGroupID == data['id'])
                                        ? Colors.yellow
                                        : Colors.black,
                                    width: 3),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: InkWell(
                                // When the Menu Group button is tapped it becomes the new selected Menu Group
                                onTap: () {
                                  setState(() {
                                    selectedMenuGroupID = data['id'];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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

                  // Retrieve the Menu Sub Groups and Menu Items of the selected Menu Group
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('MenuSubGroup')
                          .where('MenuGroupID', isEqualTo: selectedMenuGroupID)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                              'Something went wrong retrieving the menu groups');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading Menu Groups...');
                        }

                        // Display each Menu Sub Group in an expanding box which expands to show
                        // the Menu Items contained within the Menu Sub Group
                        return Expanded(
                          child: ListView(
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 1.0),
                                  elevation: 20,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                        color: Colors.black, width: 1),
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
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
                                        for (var menuItem in data['MenuItems'])
                                          Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  menuItem,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 20,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 1.25,
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
                ]);
          }),
    );
  }
}
