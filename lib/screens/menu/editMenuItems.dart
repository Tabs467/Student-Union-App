import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';
import 'createMenuItem.dart';
import 'editMenuItem.dart';

class EditMenuItems extends StatefulWidget {
  final String subGroupID;
  final String subGroupName;

  const EditMenuItems(
      {Key? key, required this.subGroupID, required this.subGroupName})
      : super(key: key);

  @override
  _EditMenuItemsState createState() => _EditMenuItemsState();
}

// Widget to display each Menu Item's information from the selected Menu
// Sub Group
// Along with an 'Edit Menu Item' and 'Delete Menu Item' button per displayed
// Menu Item
// Also a 'Create Menu Item' button is displayed at the bottom of the screen
class _EditMenuItemsState extends State<EditMenuItems> {
  final DatabaseService _database = DatabaseService();

  String subGroupID = '';
  String subGroupName = '';

  @override
  void initState() {
    subGroupID = widget.subGroupID;
    subGroupName = widget.subGroupName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Menu'),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // The title of the screen is the title of the Sub Group being edited
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
            child: buildTabTitle(subGroupName, 30),
          ),

          // Stream of the Menu Sub Group that contains the Menu Items
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('MenuSubGroup')
                  .where('id', isEqualTo: subGroupID)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                      'Something went wrong retrieving the Menu Items');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpinKitRing(
                    color: Colors.white,
                    size: 50.0,
                  );
                }

                // Determine the length of the MenuItems array for the
                // ListView Builder
                var itemCount = 0;
                if (snapshot.data!.docs[0]['MenuItems'] != null) {
                  itemCount = snapshot.data!.docs[0]['MenuItems'].length;
                }

                return Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 10.0),
                  child: ListView.builder(
                      itemCount: itemCount,
                      itemBuilder: (BuildContext context, int arrayIndex) {

                        // Check a Menu Sub Group snapshot has been returned
                        // (If not, just return an empty Container)
                        if (snapshot.data!.docs.isNotEmpty) {

                            // Check the MenuItems array is not empty
                            // (If it is, just return an empty Container)
                            var menuItemsArray = snapshot.data!.docs[0]['MenuItems'];
                            if (menuItemsArray.isNotEmpty) {
                              // Display each Menu Item
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 0.0),
                                child: Card(
                                  elevation: 20,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 5.0),
                                        child: Text(
                                          menuItemsArray[arrayIndex],
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),

                                      // Display an Edit Menu Item and a Delete
                                      // Menu Item button per displayed Menu Item
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 0.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(200, 50),
                                            maximumSize: const Size(200, 50),
                                            primary: const Color.fromRGBO(
                                                22, 66, 139, 1),
                                          ),
                                          child: const Text('Edit Menu Item'),
                                          // When tapped, navigate to the EditMenuItem
                                          // Widget with the Menu Item's details being
                                          // passed as parameters
                                          onPressed: () async {
                                            Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditMenuItem(
                                              menuItemDetails: menuItemsArray[arrayIndex],
                                              subGroupID: subGroupID,
                                            ),
                                          ),
                                        );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 0.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(200, 50),
                                            maximumSize: const Size(200, 50),
                                            primary: const Color.fromRGBO(
                                                22, 66, 139, 1),
                                          ),
                                          child: const Text('Delete Menu Item'),
                                          // When tapped delete the Menu Item from the
                                          // Menu Sub Group that contains it
                                          onPressed: () async {
                                            _database.deleteMenuItem(
                                                subGroupID,
                                                menuItemsArray[arrayIndex]);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 5.0),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                        }
                        else {
                          return Container();
                        }
                      }),
                ));
              }),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    maximumSize: const Size(150, 50),
                    primary: const Color.fromRGBO(22, 66, 139, 1),
                  ),
                  child: const Text('Create Menu Item'),
                  // When tapped navigate the user to the CreateMenuItem Widget
                  // with the id of the Sub Group passed to it
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateMenuItem(subGroupID: subGroupID,),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    maximumSize: const Size(150, 50),
                    primary: const Color.fromRGBO(22, 66, 139, 1),
                  ),
                  child: const Text('Return'),
                  // When tapped return the user back to the EditMenuSubGroup screen
                  onPressed: () async {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
