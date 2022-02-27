import 'package:flutter/material.dart';
import 'package:student_union_app/models/MenuSubGroup.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class CreateMenuSubGroup extends StatefulWidget {
  final String menuGroupID;

  const CreateMenuSubGroup({Key? key, required this.menuGroupID}) : super(key: key);

  @override
  _CreateMenuSubGroupState createState() => _CreateMenuSubGroupState();
}

// Widget to display a form to create a new Menu Sub Group
class _CreateMenuSubGroupState extends State<CreateMenuSubGroup> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String subGroupName = '';
  String error = '';

  String menuGroupID = '';

  @override
  void initState() {
    menuGroupID = widget.menuGroupID;

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
            padding: const EdgeInsets.symmetric(
                vertical: 20.0, horizontal: 30.0),
            child: buildTabTitle('Create Sub Group', 30),
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
                      hintText: 'Sub Group Name',
                    ),
                    // Sub Group Names cannot be empty and must be
                    // below 30 characters
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return "Sub Group Name cannot be empty!";
                      }
                      else if (value!.length > 30) {
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
                    child: const Text('Create Sub Group'),
                    // When the Create Sub Group button is tapped check whether the
                    // Sub Group name is valid and create a new MenuSubGroup document
                    // that contains the typed name
                    // And return the user back to the EditMenuSubGroups screen
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {

                        // Database Service handles generation of IDs
                        MenuSubGroup newMenuSubGroup = MenuSubGroup(
                            id: 'NotSet',
                            name: subGroupName,
                            menuGroupID: menuGroupID,
                            menuItems: <String>[]
                        );

                        await _database.createMenuSubGroup(newMenuSubGroup);
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
            // Return the user back to the EditMenuSubGroups screen
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
