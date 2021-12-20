import 'package:flutter/material.dart';
import 'package:student_union_app/Models/MenuGroup.dart';
import 'package:student_union_app/Models/MenuSubGroup.dart';
import 'package:student_union_app/Models/MenuItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_union_app/services/database.dart';
import 'package:student_union_app/screens/buildAppBar.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {

  String selectedMenuGroupID = '2V7MRLZ9BzIjQXYfP8ug';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 175, 20, 1),
        appBar: buildAppBar(context, 'Menu'),

        body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.
        collection('MenuGroup').snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong retrieving the menu groups');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Loading Menu Groups...');
              }

              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<
                    String,
                    dynamic>;
              });

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Material(
                    elevation: 20,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(22, 66, 139, 1),
                        border: Border(
                          bottom: BorderSide(
                            width: 1.5,
                            color: Color.fromRGBO(31, 31, 31, 1.0),
                          ),
                        )
                      ),

                      child: const Text(
                        'Food/Drink Menu',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

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
                              color: const Color.fromRGBO(
                                  22, 66, 139, 1),
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                //side: BorderSide(color: Colors.black, width: 1),
                                side: BorderSide(color: (selectedMenuGroupID == data['id']) ? Colors.yellow : Colors.black, width: 3),
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: InkWell(
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


                  StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.
                  collection('MenuSubGroup').where('MenuGroupID', isEqualTo: selectedMenuGroupID).snapshots(),
                  builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong retrieving the menu groups');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading Menu Groups...');
                    }

                    snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<
                    String,
                    dynamic>;
                    });

                    return Expanded(
                      child: ListView(
                      children: snapshot.data!.docs
                      .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                      return SizedBox(
                        width: double.infinity,
                        child: Card(
                          color: const Color.fromRGBO(
                              255, 255, 255, 1.0),
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ExpansionTile(
                              title: Text(
                                data['name'],
                                //data.toString(),
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                              children: <Widget>[
                                for(var MenuItem in data['MenuItems'] )
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          MenuItem,
                                          style: const TextStyle(
                                          fontStyle:
                                          FontStyle.italic,
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        thickness: 1.25,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      )
                      );
                      }).toList()),
                    );
                  }
              ),
              ]
              );
            }
        ),
    );
  }
}