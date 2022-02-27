import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/models/CurrentUser.dart';
import 'package:student_union_app/services/database.dart';
import '../buildAppBar.dart';
import '../buildTabTitle.dart';

class Bandaoke extends StatefulWidget {
  const Bandaoke({Key? key}) : super(key: key);

  @override
  _BandaokeState createState() => _BandaokeState();
}

// Widget to display the the Bandaoke queue with buttons to enter the queue,
// leave the queue, and the change the song that is queued by the user
class _BandaokeState extends State<Bandaoke> {
  final DatabaseService _database = DatabaseService();

  // Currently logged-in user state
  bool userAlreadyQueued = false;
  String currentUID = '';
  int currentPosition = 0;
  String chosenSongTitle = '';

  // Retrieve the currently logged-in user's UID
  Future _retrieveCurrentUID() async {
    CurrentUser currentUser = await _database.getLoggedInUserData();
    currentUID = currentUser.uid;
  }

  // Retrieve the name of a given user from their UID
  Future _retrieveName(String uid) async {
    CurrentUser currentUser = await _database.getUserData(uid);
    return currentUser.name;
  }

  // Retrieve the currently logged-in user's position in the queue
  Future _retrieveCurrentPosition() async {
    await _retrieveCurrentUID();
    currentPosition = await _database.retrievePosition(currentUID) as int;
    return currentPosition;
  }

  // Retrieve the currently logged-in user's chosen song
  Future _retrieveChosenSong() async {
    await _retrieveCurrentUID();
    chosenSongTitle = await _database.retrieveChosenSong(currentUID) as String;
    return chosenSongTitle;
  }

  // Retrieve the currently logged-in user's UID as soon as the Widget loads
  @override
  void initState() {
    _retrieveCurrentUID();
    super.initState();
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
                  itemCount = snapshot.data!.docs[0]['queuedMembers'].length;
                }

                // Logged-in user state
                userAlreadyQueued = false;

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

                              // Check the queuedMembers array is not empty
                              // (If it is, just return an empty Container)
                              var queuedMembers =
                              snapshot.data!.docs[0]['queuedMembers'];
                              if (queuedMembers.isNotEmpty) {

                                // Check whether the currently logged-in user has
                                // already entered the queue
                                if (currentUID ==
                                    queuedMembers[arrayIndex]['uid']) {
                                  userAlreadyQueued = true;
                                }

                                // Each row in the list is a FutureBuilder since a
                                // Loading Widget needs to be displayed on each row
                                // until the user's name for that row is retrieved
                                // from the database with the UID stored in the
                                // queuedMembers array element
                                return FutureBuilder(
                                    future: _retrieveName(
                                        queuedMembers[arrayIndex]['uid']),
                                    builder: (context, snapshot) {

                                      // Check whether the row entry's name has
                                      // been returned
                                      // (If it hasn't, display a Loading Widget)
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {

                                        // The row entry's name
                                        String name = snapshot.data as String;

                                        // Display the entry in the queue
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 1.0, horizontal: 0.0),
                                          child: Card(
                                            // Highlight the currently logged-in
                                            // user's queue entry
                                            color: (currentUID ==
                                                queuedMembers[arrayIndex]
                                                ['uid'])
                                                ? Colors.yellowAccent
                                                : Colors.white,
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
                                                            queuedMembers[
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
          const SizedBox(height: 10.0),

          // Display a card containing the user's position if they are
          // currently in the queue
          Card(
            elevation: 20,
            child: Column(
              children: [
                const SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),

                  // StreamBuilder used here since the card needs to react to
                  // live changes to the queuedMembers array in the database
                  child: StreamBuilder<QuerySnapshot>(
                      stream: _database.getBandaokeQueue(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text(
                              'Something went wrong retrieving the queue');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SpinKitRing(
                            color: Colors.white,
                            size: 50.0,
                          );
                        }

                        // FutureBuilder used inside the StreamBuilder since
                        // asynchronous time needs to be taken to retrieve the
                        // user's current position in the queue
                        // (Whilst the position is being retrieved a Loading
                        // Widget is returned)
                        return FutureBuilder(
                            future: _retrieveCurrentPosition(),
                            builder: (context, snapshot) {

                              // If the user's position has been returned
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {

                                // If the user is in the queue
                                if (currentPosition != 0) {
                                  // Return their current position
                                  return Text(
                                    'Current Position: ' +
                                        currentPosition.toString(),
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  );

                                  // Otherwise return the following
                                } else {
                                  return const Text(
                                    'Tap \'Queue\' to enter!',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  );
                                }

                                // Otherwise return the following
                              } else {
                                return const Text(
                                  'Tap \'Queue\' to enter!',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                );
                              }
                            });
                      }),
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
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
                  child: const Text('Change Song'),
                  // When the Change Song button is tapped
                  onPressed: () async {
                    // Determine whether the user has entered a song into the
                    // queue
                    if (userAlreadyQueued) {
                      // Retrieve which song they entered
                      // And pass it to the showChangeSongDialog Widget
                      await _retrieveChosenSong();
                      showChangeSongDialog(context, chosenSongTitle);
                    } else {
                      // If the user is not in the queue, display the following
                      // pop-up Widget
                      showNotQueuedDialog(context);
                    }
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
                  child: const Text('Dequeue'),
                  // When the Dequeue button is tapped
                  onPressed: () async {
                    // Determine whether the user has entered a song into the
                    // queue
                    if (userAlreadyQueued) {
                      // Retrieve which song they entered
                      // And pass it to the showDequeueDialog Widget
                      await _retrieveChosenSong();
                      showDequeueDialog(context, chosenSongTitle);
                    } else {
                      // If the user is not in the queue, display the following
                      // pop-up Widget
                      showNotQueuedDialog(context);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 2.5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(305, 50),
                    maximumSize: const Size(305, 50),
                    primary: const Color.fromRGBO(22, 66, 139, 1),
                  ),
                  child: const Text('Queue'),
                  // When the Queue button is tapped
                  onPressed: () async {
                    // Determine whether the user has already entered a song
                    // into the queue
                    // As only one active entry is allowed per user
                    if (!userAlreadyQueued) {
                      // If they haven't, show the new queue entry dialog
                      // pop-up Widget
                      showQueueDialog(context);
                    } else {
                      // If they have, display a pop-up Widget that informs
                      // them that they have already queued
                      showAlreadyQueuedDialog(context);
                    }
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

// The Join Queue pop-up Widget
showQueueDialog(context) {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();
  String songTitle = '';
  String error = '';

  String uid = '';

  // If the user taps "Queue", submit the form
  // Then close the pop-up
  Widget queueButton = TextButton(
    child: const Text("Queue"),
    onPressed: () async {
      // If the Song Title is valid
      if (_formKey.currentState!.validate()) {

        // Retrieve the currently logged-in user's UID and pass it to the
        // queue function in the database service
        CurrentUser currentUser = await _database.getLoggedInUserData();
        uid = currentUser.uid;
        await _database.queue(uid, songTitle);

        // Close the pop-up
        Navigator.of(context).pop();
      }
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
    title: const Text("Join the Queue"),
    content: SizedBox(
      height: 70,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Song Name',
              ),
              // Song Names cannot be empty and must be
              // below 30 characters
              validator: (String? value) {
                if (value != null && value.isEmpty) {
                  return "Song Name cannot be empty!";
                } else if (value!.length > 30) {
                  return "Song Name must be below 30 characters!";
                }
                return null;
              },
              onChanged: (val) {
                songTitle = val;
              },
            ),
            // Error text
            Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      queueButton,
      cancelButton,
    ],
  );

  // The function to build the Join Queue dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// The already queued pop-up Widget
showAlreadyQueuedDialog(context) {
  // If the user taps "Ok", close the pop-up
  Widget cancelButton = TextButton(
    child: const Text("Ok"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // The alert dialog box
  AlertDialog alert = AlertDialog(
    title: const Text("You have already entered the queue!"),
    content: const Text("You can only queue one song at a time!"),
    actions: [
      cancelButton,
    ],
  );

  // The function to build the AlreadyQueued alert dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// The Not Queued pop-up Widget
showNotQueuedDialog(context) {
  // If the user taps "Ok", close the pop-up
  Widget okButton = TextButton(
    child: const Text("Ok"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // The alert dialog box
  AlertDialog alert = AlertDialog(
    title: const Text("You are not in the queue!"),
    content: const Text("Press the \'Queue\' button to join the queue!"),
    actions: [
      okButton,
    ],
  );

  // The function to build the Not Queued alert dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// The Dequeue pop-up Widget
showDequeueDialog(context, songTitle) {
  final DatabaseService _database = DatabaseService();

  String uid = '';

  // If the user taps "Yes", remove the user from the queue
  // Then close the pop-up
  Widget yesButton = TextButton(
    child: const Text("Yes"),
    onPressed: () async {

      // Retrieve the currently logged-in user's UID and pass it to the
      // dequeue function in the database service
      CurrentUser currentUser = await _database.getLoggedInUserData();
      uid = currentUser.uid;
      await _database.dequeue(uid, songTitle);

      // Close the pop-up
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
    content: const Text("Are you sure you want to leave the queue?"),
    actions: [
      yesButton,
      cancelButton,
    ],
  );

  // The function to build the Dequeue dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// The Change Song pop-up Widget
showChangeSongDialog(context, chosenSongTitle) {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();
  String songTitle = chosenSongTitle;
  String error = '';

  String uid = '';

  // If the user taps "Change Song", submit the form
  // Then close the pop-up
  Widget changeSongButton = TextButton(
    child: const Text("Change Song"),
    onPressed: () async {
      // If the new song title is valid
      if (_formKey.currentState!.validate()) {

        // Retrieve the currently logged-in user's UID and pass it to the
        // changeSong function in the database service
        CurrentUser currentUser = await _database.getLoggedInUserData();
        uid = currentUser.uid;
        await _database.changeSong(uid, songTitle);

        // Close the pop-up Widget
        Navigator.of(context).pop();
      }
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
    title: const Text("Change Song"),
    content: SizedBox(
      height: 70,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              initialValue: songTitle,
              decoration: const InputDecoration(
                hintText: 'Song Name',
              ),
              // Song Names cannot be empty and must be
              // below 30 characters
              validator: (String? value) {
                if (value != null && value.isEmpty) {
                  return "Song Name cannot be empty!";
                } else if (value!.length > 30) {
                  return "Song Name must be below 30 characters!";
                }
                return null;
              },
              onChanged: (val) {
                songTitle = val;
              },
            ),
            // Error text
            Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      changeSongButton,
      cancelButton,
    ],
  );

  // The function to build the Change Song alert dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
