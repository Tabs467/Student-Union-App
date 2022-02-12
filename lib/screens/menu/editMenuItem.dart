import 'package:flutter/material.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class EditMenuItem extends StatefulWidget {
  final String subGroupID;
  final String menuItemDetails;

  const EditMenuItem(
      {Key? key, required this.subGroupID, required this.menuItemDetails})
      : super(key: key);

  @override
  _EditMenuItemState createState() => _EditMenuItemState();
}

// Widget to display a form to edit a Menu Item
class _EditMenuItemState extends State<EditMenuItem> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Text field state
  String subGroupID = '';
  String originalMenuItemDetails = '';
  String menuItemName = '';
  String menuItemPrice = '';
  String error = '';

  @override
  void initState() {
    subGroupID = widget.subGroupID;
    originalMenuItemDetails = widget.menuItemDetails;

    // Retrieve Menu Item and Price from the MenuItems entry
    menuItemName = widget.menuItemDetails.substring(0,
                                       widget.menuItemDetails.indexOf('£') - 3);

    menuItemPrice = widget.menuItemDetails.substring(
                                       widget.menuItemDetails.indexOf('£') + 1,
                                       widget.menuItemDetails.length);
    
    super.initState();
  }

  // Check whether a given string is a Numeric
  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }

    return double.tryParse(str) != null;
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
            child: buildTabTitle('Edit Menu Item', 40),
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
                    initialValue: menuItemName,
                    decoration: const InputDecoration(
                      hintText: 'Menu Item Name',
                    ),
                    // Menu Item Names cannot be empty and must be
                    // below 40 characters
                    // And must not contain the '£' character
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return "Menu Item Name cannot be empty!";
                      } else if (value!.length > 40) {
                        return "Menu Item Name must be below 40 characters!";
                      }
                      else if (value.contains('£')) {
                        return "Menu Item Name cannot contain the '£' symbol!";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        menuItemName = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: menuItemPrice,
                    decoration: const InputDecoration(
                      hintText: 'Menu Item Price',
                    ),
                    // Menu Item Price cannot be empty and must be
                    // a number
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return "Menu Item Price cannot be empty!";
                      }
                      else if (!_isNumeric(value!)) {
                        return "Menu Item Price must be a number!";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        menuItemPrice = val;
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
                    // the name and price are valid and update the entry in
                    // the MenuItems array in the MenuSubGroup document to
                    // contain the updated details
                    // And return the user back to the EditMenuItems screen
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {

                        // Format MenuItem entry
                        // Keep only up to two decimal places on the price
                        menuItemPrice = double.parse((double.parse(menuItemPrice)).toStringAsFixed(2)).toString();

                        String newMenuItemDetails = menuItemName + " - £" + menuItemPrice;

                        await _database.updateMenuItem(
                            subGroupID,
                            originalMenuItemDetails,
                            newMenuItemDetails);
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
            // Return the user back to the EditMenuItems screen
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
