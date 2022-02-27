import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/MenuGroup.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';
import 'editMenuGroup.dart';

class EditMenuGroups extends StatefulWidget {
  const EditMenuGroups({Key? key}) : super(key: key);

  @override
  _EditMenuGroupsState createState() => _EditMenuGroupsState();
}

// Widget to display the list of the Menu Groups stored in the Menu Groups
// collection
// Along with buttons to edit and delete them
// (the delete button also has a confirmation pop-up)
// And also a button that leads to a screen to create a new Menu Group
class _EditMenuGroupsState extends State<EditMenuGroups> {
  final DatabaseService _database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Menu'),

      // Set up the stream that retrieves and listens to all the Menu Group
      // documents inside the MenuGroup collection
      body: StreamBuilder<QuerySnapshot>(
          stream: _database.getMenuGroups(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong retrieving the Menu Groups');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50.0),
                    child: buildTabTitle('Edit Menu Groups', 30),
                  ),
                  const SizedBox(height: 20.0),
                  const SpinKitRing(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ],
              );
            }

            return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 50.0),
                    child: buildTabTitle('Edit Menu Groups', 30),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 25.0),
                      child: ListView(
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;

                              // Create a MenuGroup object per retrieved MenuGroup
                              MenuGroup menuGroup = _database.menuGroupFromSnapshot(data);

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
                                            vertical: 5.0, horizontal: 0.0),
                                        child: Text(
                                          menuGroup.name!,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 25.0),
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
                                          child: const Text('Edit Menu Group'),
                                          // If the edit button on a group is
                                          // tapped navigate the user to the
                                          // EditMenuGroup Widget with the
                                          // Menu Group ID passed as
                                          // a parameter
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditMenuGroup(
                                                      menuGroupID: menuGroup.id!,
                                                      name: menuGroup.name!,
                                                    ),
                                              )
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
                                          child: const Text('Delete Menu Group'),
                                          // If the delete group button is tapped
                                          // display the deleteAlert pop-up
                                          onPressed: () async {
                                            showDeleteAlertDialog(context, menuGroup.id!);
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 0.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Create New Menu Group'),
                      // When tapped navigate the user to the CreateMenuGroup screen
                      onPressed: () async {
                        Navigator.pushNamed(context, '/menu/createMenuGroup');
                      },
                    ),
                  ),
                ]);
          }),
    );
  }
}

// The delete Menu Group confirmation pop-up Widget
showDeleteAlertDialog(context, id) {
  final DatabaseService _database = DatabaseService();

  // If the user taps "Yes", delete all MenuSubGroup documents related to
  // the Menu Group and the Menu Group document itself
  // Then close the pop-up
  Widget yesButton = TextButton(
    child: const Text("Yes"),
    onPressed: () async {
      await _database.deleteMenuGroup(id);
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
        "Deleting this Menu Group will also delete all of the Sub Groups contained "
            "plus all the Menu Items contained within those subgroups! "
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
