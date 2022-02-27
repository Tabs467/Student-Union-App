import 'package:flutter/material.dart';
import 'package:student_union_app/models/MenuGroup.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class CreateMenuGroup extends StatefulWidget {
  const CreateMenuGroup({Key? key}) : super(key: key);

  @override
  _CreateMenuGroupState createState() => _CreateMenuGroupState();
}

// Widget to display a form to create a new Menu Group
class _CreateMenuGroupState extends State<CreateMenuGroup> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String menuGroupName = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Menu'),
      resizeToAvoidBottomInset: false,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 20.0, horizontal: 30.0),
            child: buildTabTitle('Create Menu Group', 30),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Menu Group Name',
                    ),
                    // Menu Group Names cannot be empty and must be
                    // below 40 characters
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return "Menu Group Name cannot be empty!";
                      }
                      else if (value!.length > 40) {
                        return "Menu Group Name must be below 40 characters!";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        menuGroupName = val;
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
                    child: const Text('Create Menu Group'),
                    // When the Create Menu Group button is tapped check whether the
                    // Menu Group name is valid and create a new MenuGroup document
                    // that contains the typed name
                    // And return the user back to the EditMenuGroups screen
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {

                        // Database Service handles generation of IDs
                        MenuGroup newMenuGroup = MenuGroup(
                            id: 'NotSet', name: menuGroupName
                        );

                        await _database.createMenuGroup(newMenuGroup);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
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
