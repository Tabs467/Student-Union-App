import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';
import 'editMenuSubGroups.dart';

class EditMenuGroup extends StatefulWidget {
  final String menuGroupID;
  final String name;

  const EditMenuGroup({Key? key, required this.menuGroupID, required this.name})
      : super(key: key);

  @override
  _EditMenuGroupState createState() => _EditMenuGroupState();
}

// Widget to display a form to edit a Menu Group name
// Along with a button that navigates to a Widget to edit the Sub Groups
// contained within the Menu Group
class _EditMenuGroupState extends State<EditMenuGroup> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String menuGroupID = '';
  String name = '';
  String error = '';

  @override
  void initState() {
    menuGroupID = widget.menuGroupID;
    name = widget.name;
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
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: buildTabTitle('Edit Menu Group', 40),
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
                    initialValue: name,
                    decoration: const InputDecoration(
                      hintText: 'Menu Group Name',
                    ),
                    // Menu Group Names cannot be empty and must be
                    // below 30 characters
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return "Menu Group Name cannot be empty!";
                      } else if (value!.length > 30) {
                        return "Menu Group Name must be below 30 characters!";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        name = val;
                      });
                    },
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
                    // the name is valid and update the MenuGroup document
                    // to the new name
                    // And return the user back to the EditMenuGroups screen
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _database.updateMenuGroup(menuGroupID, name);
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
            child: const Text('Edit Sub Groups'),
            // Pass the name and id of the MenuGroup to the EditMenuSubGroups
            // Widget and navigate to it
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditMenuSubGroups(
                    menuGroupID: menuGroupID,
                    menuGroupName: name,
                  ),
                ),
              );
            },
          ),
          // To create padding so the Return button is displayed at the bottom
          // of the screen
          Expanded(
            child: Container(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              maximumSize: const Size(200, 50),
              primary: const Color.fromRGBO(22, 66, 139, 1),
            ),
            child: const Text('Return'),
            // Return the user back to the EditMenuGroups screen
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}
