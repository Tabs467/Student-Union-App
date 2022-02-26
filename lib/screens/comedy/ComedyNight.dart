import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ComedyNight extends StatefulWidget {
  const ComedyNight({Key? key}) : super(key: key);

  @override
  _ComedyNightState createState() => _ComedyNightState();
}

// Widget to display the Comedy Night schedule along with each comedian and
// their social media link buttons (where each button will either open the
// comedian's profile by opening the related app or displaying the page on the
// phone's default browser - depending on the user's phone settings)
class _ComedyNightState extends State<ComedyNight> {
  final DatabaseService _database = DatabaseService();

  // Whether the currently logged-in user is an admin
  bool _isAdmin = false;


  // Format a timestamp to just display the time as hh:mm
  String _timeFromTimeStamp(Timestamp timeStamp) {

    // Calculate DateTime from TimeStamp
    DateTime unformattedDate = DateTime.parse(
        timeStamp.toDate().toString());

    // Format DateTime for output
    String time = "${unformattedDate.hour.toString()}"
        ":${unformattedDate.minute.toString().padLeft(2, '0')}";

    return time;
  }


  // Return whether a social media link has been set
  bool _linkSet(String link) {
    return link != "Not Set";
  }


  // Launch a url in the user's default app or browser
  _launchURL(String url) async {

    // URLs to launch Facebook profile in the Facebook app and on the default
    // web browser are different
    // So create a backup URL to launch the profiles in the default web browser
    // in case the user does not have the Facebook app installed
    String backUpFacebookURL = '';

    // If the inputted URL is a Facebook profile link
    if (url.substring(0, 25) == "fb://facewebmodal/f?href=") {
      // Remove extra characters at the start of the string to launch the
      // profile in the default web browser
      backUpFacebookURL = url.substring(25);
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // If the URL can't be launched and it is a Facebook URL
      if (backUpFacebookURL != null) {
        // Check whether the Facebook URL can be launched in the default web
        // browser rather than the Facebook app
        if (await canLaunch(backUpFacebookURL)) {
          await launch(backUpFacebookURL);
        }
        else {
          throw "Could not launch: " + url;
        }
      }
      throw "Could not launch: " + url;
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        // Rebuilt when the asynchronous function determines whether there is a
        // currently logged-in admin
        future: _database.userAdmin(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          // When the asynchronous function is complete build the Comedy Night
          // Widget instead of a Loading Widget
          if (snapshot.hasData) {

            // Determine whether the currently logged-in user is an admin
            if (snapshot.data == true) {
              _isAdmin = true;
            }

            return Scaffold(
                backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                appBar: buildAppBar(context, 'Comedy'),

                // Stream of snapshots of the ComedyNightSchedule document
                body: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('ComedyNightSchedule')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text(
                            'Something went wrong retrieving the Comedy Night Schedule');
                      }
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SpinKitRing(
                          color: Colors.white,
                          size: 150.0,
                        );
                      }


                      // Calculate DateTime of the Comedy Night from the
                      // TimeStamp stored in the ComedyNightSchedule document
                      DateTime unformattedDate = DateTime.parse(snapshot
                          .data!.docs[0]['date']
                          .toDate()
                          .toString());

                      // Format DateTime for output
                      String date =
                          "${unformattedDate.day.toString().padLeft(2, '0')}"
                          "/${unformattedDate.month.toString().padLeft(2, '0')}"
                          "/${unformattedDate.year.toString()}"
                          " at ${unformattedDate.hour.toString()}"
                          ":${unformattedDate.minute.toString().padLeft(2, '0')}";

                      // Concatenate am or pm depending on the
                      // time of day stored
                      if (unformattedDate.hour <= 12) {
                        date += "am";
                      } else {
                        date += "pm";
                      }


                      // Create the local comedians array and determine the
                      // length of the comedians array for the ListView Builder
                      var itemCount = 0;
                      var comediansArray = [];
                      // If the comedians array exists within the document
                      if (snapshot.data!.docs[0]['comedians'] != null) {

                        // Calculate the document's comedians array length
                        itemCount = snapshot.data!.docs[0]['comedians'].length;

                        // Create a local copy of the array
                        comediansArray = snapshot.data!.docs[0]['comedians'];

                        // If the arrays are not empty
                        if (comediansArray.isNotEmpty) {
                          // If there is more than one comedian in each array
                          // sort the comedians by their start time so the
                          // schedule is outputted in the correct order
                          if (comediansArray.length > 1) {

                            // Sort comedians by start time using Bubble Sort
                            for (int arrayIndex = comediansArray.length -
                                2; arrayIndex >= 0; arrayIndex--) {

                              // If the next element in the array has an earlier
                              // start time
                              if (comediansArray[arrayIndex]['startTime']
                                  .compareTo(comediansArray[arrayIndex +
                                  1]['startTime']) > 0) {

                                // Swap the array elements
                                var temp = comediansArray[arrayIndex];
                                comediansArray[arrayIndex] = comediansArray[arrayIndex + 1];
                                comediansArray[arrayIndex + 1] = temp;
                              }
                            }
                          }
                        }
                      }


                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 30.0),
                            child: buildTabTitle('Comedy Night', 40),
                          ),

                          // Display the Comedy Night's date and time
                          Card(
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.blue, width: 2),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                date,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),

                          // Display each comedian in the local comedians array
                          // now that they are in the order of their start times
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 10.0),
                              child: ListView.builder(
                                  itemCount: itemCount,
                                  itemBuilder: (BuildContext context, int arrayIndex) {

                                    // Check a ComedyNightSchedule snapshot has been returned
                                    // (If not, just return an empty Container)
                                    if (snapshot.data!.docs.isNotEmpty) {

                                      // Check the comedians array is not empty
                                      // (If it is, just return an empty Container)
                                      if (comediansArray.isNotEmpty) {

                                        // Main act is determined by the last
                                        // act of the night
                                        bool mainAct = false;
                                        if (arrayIndex == comediansArray.length - 1) {
                                          mainAct = true;
                                        }


                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3.0, horizontal: 0),
                                          child: ClipRRect(
                                            child: Card(
                                              shape: Border(
                                                // Main act has a purple border
                                                // instead of a blue one
                                                left: BorderSide(
                                                    color: (mainAct) ? Colors.purple : const Color.fromRGBO(22, 66, 139, 1),
                                                    width: 10
                                                ),
                                              ),

                                              elevation: 5,
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 5.0),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        vertical: 5.0, horizontal: 5.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          _timeFromTimeStamp(comediansArray[arrayIndex]['startTime'])
                                                              + " - "
                                                              + _timeFromTimeStamp(comediansArray[arrayIndex]['endTime']),
                                                          style: const TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 25,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10.0),
                                                        Text(
                                                          comediansArray[arrayIndex]['name'],
                                                          style: const TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 25,
                                                          ),
                                                        ),

                                                        // Each social media icon button
                                                        // is only displayed if the link
                                                        // they lead to has been set in
                                                        // the comedians array
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            (_linkSet(comediansArray[arrayIndex]['facebook'])) ? Padding(
                                                                padding: const EdgeInsets.all(6.0),
                                                                child: IconButton(
                                                                  onPressed: () async {
                                                                    await _launchURL(comediansArray[arrayIndex]['facebook']);
                                                                  },
                                                                  iconSize: (50),
                                                                  icon: const Icon(
                                                                    FontAwesomeIcons.facebook,
                                                                    color: Color.fromRGBO(59, 89, 152, 1),
                                                                    //size: 50.0,
                                                                  ),
                                                                ),
                                                              )
                                                            :
                                                            Container(),
                                                            (_linkSet(comediansArray[arrayIndex]['instagram'])) ? Padding(
                                                              padding: const EdgeInsets.all(6.0),
                                                              child: IconButton(
                                                                onPressed: () async {
                                                                  await _launchURL(comediansArray[arrayIndex]['instagram']);
                                                                },
                                                                iconSize: (50),
                                                                icon: const Icon(
                                                                  FontAwesomeIcons.instagram,
                                                                  color: Color.fromRGBO(131, 58, 180, 1),
                                                                  //size: 50.0,
                                                                ),
                                                              ),
                                                            )
                                                                :
                                                            Container(),
                                                            (_linkSet(comediansArray[arrayIndex]['twitter'])) ? Padding(
                                                              padding: const EdgeInsets.all(6.0),
                                                              child: IconButton(
                                                                onPressed: () async {
                                                                  await _launchURL(comediansArray[arrayIndex]['twitter']);
                                                                },
                                                                iconSize: (50),
                                                                icon: const Icon(
                                                                  FontAwesomeIcons.twitter,
                                                                  color: Color.fromRGBO(29, 161, 242, 1),
                                                                  //size: 50.0,
                                                                ),
                                                              ),
                                                            )
                                                                :
                                                            Container(),
                                                            (_linkSet(comediansArray[arrayIndex]['snapchat'])) ? Padding(
                                                              padding: const EdgeInsets.all(6.0),
                                                              child: IconButton(
                                                                onPressed: () async {
                                                                  await _launchURL(comediansArray[arrayIndex]['snapchat']);
                                                                },
                                                                iconSize: (50),
                                                                icon: const Icon(
                                                                  FontAwesomeIcons.snapchat,
                                                                  color: Color.fromRGBO(244, 175, 20, 1),
                                                                  //size: 50.0,
                                                                ),
                                                              ),
                                                            )
                                                                :
                                                            Container(),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }
                                    else {
                                      return Container();
                                    }
                                  }),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ],
                      );
                    }),

                // If the logged-in user is an admin display the admin
                // floating action button
                floatingActionButton: (_isAdmin) ? SizedBox(
                  height: 200.0,
                  width: 145.0,
                  child: FittedBox(
                    child: FloatingActionButton.extended(
                      // When tapped, navigate the user to the
                      // Comedy Night admin Widget
                      onPressed: () {
                        Navigator.pushNamed(context, '/comedy/comedyNightAdmin');
                      },
                      backgroundColor:
                      const Color.fromRGBO(22, 66, 139, 1),
                      label: const Text('Edit Schedule'),
                      icon:
                      const Icon(Icons.admin_panel_settings_rounded),
                    ),
                  ),
                ) :
                Container()
            );

            // Build a loading Widget whilst the asynchronous function takes
            // time to complete
          } else {
            return Scaffold(
                backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
                appBar: buildAppBar(context, 'Comedy'),
                body: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      child: buildTabTitle('Comedy Night', 40),
                    ),
                    const SpinKitRing(
                      color: Colors.white,
                      size: 150.0,
                    ),
                  ],
                ));
          }
        });
  }
}
