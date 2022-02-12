import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';
import 'createMenuSubGroup.dart';
import 'editMenuSubGroup.dart';

class EditMenuSubGroups extends StatefulWidget {
  final String menuGroupID;
  final String menuGroupName;

  const EditMenuSubGroups(
      {Key? key, required this.menuGroupID, required this.menuGroupName})
      : super(key: key);

  @override
  _EditMenuSubGroupsState createState() => _EditMenuSubGroupsState();
}

// Widget to display each Menu Sub Group's information from the selected Menu
// Group
// Along with an 'Edit Sub Group' and 'Delete Sub Group' button per displayed
// Menu Sub Group
// Also a 'Create Sub Group' button is displayed at the bottom of the screen
class _EditMenuSubGroupsState extends State<EditMenuSubGroups> {
  String menuGroupID = '';
  String menuGroupName = '';

  @override
  void initState() {
    menuGroupID = widget.menuGroupID;
    menuGroupName = widget.menuGroupName;
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
          // The title of the screen is the title of the Menu Group being edited
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
            child: buildTabTitle(menuGroupName, 30),
          ),

          // Stream of Sub Groups contained within the Menu Group
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('MenuSubGroup')
                  .where('MenuGroupID', isEqualTo: menuGroupID)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                      'Something went wrong retrieving the Sub Groups');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading Sub Groups...');
                }

                return Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 10.0),
                    child: ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                          // Format the MenuItems array for output to the user
                          var menuItems = data['MenuItems'];
                          String menuItemsOutput = '';
                          if (menuItems.isNotEmpty) {
                            // Display each Menu Item in a vertical list
                            for (var item in menuItems) {
                              menuItemsOutput += item + '\n';
                            }
                            // Remove the last extra new line character at the end
                            menuItemsOutput = menuItemsOutput.substring(
                                0, menuItemsOutput.length - 1);
                          }

                          // Display each Menu Sub Group
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
                                          data['name'],
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 5.0),
                                    child: Text(
                                      menuItemsOutput,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),

                                  // Display an Edit Sub Group and a Delete
                                  // Sub Group button per displayed Sub Group
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 0.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(200, 50),
                                        maximumSize: const Size(200, 50),
                                        primary:
                                        const Color.fromRGBO(22, 66, 139, 1),
                                      ),
                                      child: const Text('Edit Sub Group'),
                                      // When tapped, navigate to the EditSubGroup
                                      // Widget with the Sub Group's details being
                                      // passed as parameters
                                      onPressed: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditMenuSubGroup(
                                              subGroupID: data['id'],
                                              subGroupName: data['name'],
                                              formattedMenuItems: menuItemsOutput,
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
                                        primary:
                                        const Color.fromRGBO(22, 66, 139, 1),
                                      ),
                                      child: const Text('Delete Sub Group'),
                                      // If the delete Sub Group button is tapped
                                      // display the deleteAlert pop-up
                                      onPressed: () async {
                                        showDeleteAlertDialog(context, data['id']);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                ],
                              ),
                            ),
                          );
                        }).toList()),
                  ),
                );
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
                  child: const Text('Create Sub Group'),
                  // When tapped navigate the user to the CreateMenuSubGroup Widget
                  // with the id of the overall Menu Group passed to it
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateMenuSubGroup(menuGroupID: menuGroupID,),
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
                  // When tapped return the user back to the EditMenuGroup screen
                  onPressed: () async {
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

// The delete Menu Sub Group confirmation pop-up Widget
showDeleteAlertDialog(context, id) {
  final DatabaseService _database = DatabaseService();

  // If the user taps "Yes", delete the MenuSubGroup document
  // Then close the pop-up
  Widget yesButton = TextButton(
    child: const Text("Yes"),
    onPressed: () async {
      await _database.deleteMenuSubGroup(id);
      Navigator.of(context).pop();
    },
  );

  // If the user taps "Cancel", just close the pop-up
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // The alert dialog box
  AlertDialog alert = AlertDialog(
    title: const Text("Warning!"),
    content: const Text(
        "Deleting this Menu Sub Group will also delete all of the Menu Items"
            " contained within it! "
            "Are you sure you want to continue?"),
    actions: [
      yesButton,
      cancelButton,
    ],
  );

  // The function to build the delete alert dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}