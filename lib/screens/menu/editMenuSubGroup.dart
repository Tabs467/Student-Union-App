import 'package:flutter/material.dart';
import 'package:student_union_app/models/MenuSubGroup.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';
import 'editMenuItems.dart';

class EditMenuSubGroup extends StatefulWidget {
  final String subGroupID;
  final String subGroupName;
  final String formattedMenuItems;

  const EditMenuSubGroup(
      {Key? key,
      required this.subGroupID,
      required this.subGroupName,
      required this.formattedMenuItems})
      : super(key: key);

  @override
  _EditMenuSubGroupState createState() => _EditMenuSubGroupState();
}

// Widget to display a form to edit a Menu Sub Group
// The Sub Group's Menu Items are also displayed in a vertical list
// Along with a button that navigates to a Widget to edit the Menu Items
// contained within the Sub Group
class _EditMenuSubGroupState extends State<EditMenuSubGroup> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String subGroupID = '';
  String subGroupName = '';
  String formattedMenuItems = '';
  String error = '';

  @override
  void initState() {
    subGroupID = widget.subGroupID;
    subGroupName = widget.subGroupName;
    formattedMenuItems = widget.formattedMenuItems;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Menu'),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: buildTabTitle('Edit Sub Group', 40),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20.0),
                    TextFormField(
                      initialValue: subGroupName,
                      decoration: const InputDecoration(
                        hintText: 'Sub Group Name',
                      ),
                      // Sub Group Names cannot be empty and must be
                      // below 30 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Sub Group Name cannot be empty!";
                        } else if (value!.length > 30) {
                          return "Sub Group Name must be below 30 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          subGroupName = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      formattedMenuItems,
                    ),
                    const SizedBox(height: 12.0),
                    // Error text
                    Text(
                      error,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 18.0,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        primary: const Color.fromRGBO(22, 66, 139, 1),
                      ),
                      child: const Text('Submit Changes'),
                      // When the Submit Changes button is tapped check whether
                      // the name is valid and update the MenuSubGroup document
                      // to the new name
                      // And return the user back to the EditMenuSubGroups screen
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {

                          // MenuGroupID and MenuItems are not needed in the
                          // updateMenuSubGroup function
                          MenuSubGroup menuSubGroup = MenuSubGroup(
                              id: subGroupID,
                              name: subGroupName,
                              menuGroupID: 'Not Set',
                              menuItems: <String>[]
                          );


                          await _database.updateMenuSubGroup(menuSubGroup);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                primary: const Color.fromRGBO(22, 66, 139, 1),
              ),
              child: const Text('Edit Menu Items'),
              // Pass the name and id of the MenuSubGroup to the EditMenuItems
              // Widget and navigate to it
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditMenuItems(
                      subGroupName: subGroupName,
                      subGroupID: subGroupID,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                primary: const Color.fromRGBO(22, 66, 139, 1),
              ),
              child: const Text('Return'),
              // Return the user back to the EditMenuSubGroups screen
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 25.0),
          ],
        ),
      ),
    );
  }
}
