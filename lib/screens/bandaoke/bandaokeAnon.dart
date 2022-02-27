import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/BandaokeQueue.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class BandaokeAnon extends StatefulWidget {
  const BandaokeAnon({Key? key}) : super(key: key);

  @override
  _BandaokeAnonState createState() => _BandaokeAnonState();
}

// Widget to display the the Bandaoke queue without any buttons to enter it
class _BandaokeAnonState extends State<BandaokeAnon> {
  final DatabaseService _database = DatabaseService();

  // Retrieve the name of a given user from their UID
  Future _retrieveName(String uid) async {
    CurrentUser currentUser = await _database.getUserData(uid);
    return currentUser.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Bandaoke'),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: buildTabTitle('Bandaoke', 40),
          ),
          // Listen to the stream containing snapshots of the bandaoke queue
          StreamBuilder<QuerySnapshot>(
              stream: _database.getBandaokeQueue(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                      'Something went wrong retrieving the queue');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SpinKitRing(
                    color: Colors.white,
                    size: 50.0,
                  );
                }

                // Determine the length of the queuedMembers array in the
                // BandaokeQueue document for the ListView Builder
                var itemCount = 0;
                if (snapshot.data!.docs[0]['queuedMembers'] != null) {

                  BandaokeQueue bandaokeQueue =
                  _database.bandaokeQueueFromSnapshot(snapshot.data!.docs[0]);

                  itemCount = bandaokeQueue.queuedMembers!.length;
                }

                return Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 25.0),
                      child: ListView.builder(
                          itemCount: itemCount,
                          itemBuilder: (BuildContext context, int arrayIndex) {

                            // Check a BandaokeQueue snapshot has been returned
                            // (If not, just return an empty Container)
                            if (snapshot.data!.docs.isNotEmpty) {

                              BandaokeQueue bandaokeQueue =
                              _database.bandaokeQueueFromSnapshot(snapshot.data!.docs[0]);

                              // Check the queuedMembers array is not empty
                              // (If it is, just return an empty Container)
                              if (bandaokeQueue.queuedMembers!.isNotEmpty) {

                                // Each row in the list is a FutureBuilder since a
                                // Loading Widget needs to be displayed on each row
                                // until the user's name for that row is retrieved
                                // from the database with the UID stored in the
                                // queuedMembers array element
                                return FutureBuilder(
                                    future: _retrieveName(
                                        bandaokeQueue.queuedMembers![arrayIndex]['uid']),
                                    builder: (context, snapshot) {

                                      // Check whether the row entry's name has
                                      // been returned
                                      // (If it hasn't, display a Loading Widget)
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {

                                        // The row entry's name
                                        String name = snapshot.data.toString();

                                        // Display the entry in the queue
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1.0, horizontal: 0.0),
                                          child: Card(
                                            color: Colors.white,
                                            elevation: 20,
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 5.0),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 20.0),
                                                      child: Text(
                                                        (arrayIndex + 1).toString(),
                                                        style: const TextStyle(
                                                          fontStyle:
                                                          FontStyle.italic,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5.0,
                                                          horizontal: 5.0),
                                                      child: Text(
                                                        name +
                                                            "\n" +
                                                            bandaokeQueue.queuedMembers![
                                                            arrayIndex]
                                                            ['songTitle'],
                                                        style: const TextStyle(
                                                          fontStyle:
                                                          FontStyle.italic,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5.0),
                                              ],
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SpinKitRing(
                                          color: Colors.white,
                                          size: 50.0,
                                        );
                                      }
                                    });
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          }),
                    ));
              }),
          const SizedBox(height: 25.0),
        ],
      ),
    );
  }
}