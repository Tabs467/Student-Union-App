import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'CreateComedian.dart';
import 'EditComedian.dart';

class ComedyNightAdmin extends StatefulWidget {
  const ComedyNightAdmin({Key? key}) : super(key: key);

  @override
  _ComedyNightAdminState createState() => _ComedyNightAdminState();
}

// Widget to edit the Comedy Night schedule and comedians
class _ComedyNightAdminState extends State<ComedyNightAdmin> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();


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

    // URLs to launch Facebook profiles in the Facebook app and on the default
    // web browser are different
    // So create a backup URL to launch the profile in the default web browser
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


  // The DateTime of the Comedy Night set by the user
  late DateTime selectedDateTime;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Comedy'),
      body: StreamBuilder<QuerySnapshot>(

          // Stream of snapshots of the ComedyNightSchedule document
          stream: _database.getComedyNightSchedule(),
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
            DateTime defaultDate = DateTime.parse(snapshot
                .data!.docs[0]['date']
                .toDate()
                .toString());


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
                  child: buildTabTitle('Edit Schedule', 40),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 8.0, 12.0, 8.0),

                  // Form to edit the Comedy Night's date and time
                  child: Row(
                    children: [
                      Form(
                        key: _formKey,
                        child: Expanded(
                          child: DateTimeField(
                            format: DateFormat("yyyy-MM-dd HH:mm"),

                            // Initial date is the date stored in the
                            // ComedyNightSchedule document
                            initialValue: defaultDate,

                            // Selected DateTime cannot be empty
                            validator: (DateTime? value) {
                              if (value == null) {
                                return "Start Date and Time cannot be empty!";
                              }
                              return null;
                            },

                            onShowPicker: (context, currentValue) async {

                              final date = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));

                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime:
                                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                );

                                selectedDateTime = DateTimeField.combine(date, time);

                                return DateTimeField.combine(date, time);
                              } else {
                                return currentValue;
                              }
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(75, 50),
                            maximumSize: const Size(75, 50),
                            primary: const Color.fromRGBO(22, 66, 139, 1),
                          ),
                          child: const Text('Set'),
                          // When the Set button is tapped, validate that a
                          // DateTime has been entered and use the following
                          // database service function to update the
                          // ComedyNightSchedule document
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await _database.updateComedyDate(selectedDateTime);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5.0),

                // Display each comedian in the local comedians array
                // now that they are in the order of their start times
                // And display an Edit Comedian and a Delete Comedian button
                // per outputted comedian
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
                                        width: 10,
                                      )
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


                                              // Display an Edit Comedian and a Delete Comedian
                                              // button per displayed comedian
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 5.0, horizontal: 0.0),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    minimumSize: const Size(200, 50),
                                                    maximumSize: const Size(200, 50),
                                                    primary:
                                                    const Color.fromRGBO(22, 66, 139, 1),
                                                  ),
                                                  child: const Text('Edit Comedian'),
                                                  // When tapped, navigate to the EditComedian
                                                  // Widget with the comedian's details being
                                                  // passed as parameters
                                                  onPressed: () async {
                                                    Navigator.push(
                                                      context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditComedian(comedianID: comediansArray[arrayIndex]['id'],
                                                                  comedianName: comediansArray[arrayIndex]['name'],
                                                                  startDateTime: comediansArray[arrayIndex]['startTime'],
                                                                  endDateTime: comediansArray[arrayIndex]['endTime'],
                                                                  facebook: comediansArray[arrayIndex]['facebook'],
                                                                  instagram: comediansArray[arrayIndex]['instagram'],
                                                                  twitter: comediansArray[arrayIndex]['twitter'],
                                                                  snapchat: comediansArray[arrayIndex]['snapchat']
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
                                                    primary:
                                                    const Color.fromRGBO(22, 66, 139, 1),
                                                  ),
                                                  child: const Text('Delete Comedian'),
                                                  // When tapped, display the delete comedian
                                                  // pop-up dialogue box - passing the
                                                  // comedian's details as parameters
                                                  onPressed: () async {
                                                    showDeleteAlertDialog(
                                                      context,
                                                      comediansArray[arrayIndex]['id'],
                                                      comediansArray[arrayIndex]['name'],
                                                      comediansArray[arrayIndex]['startTime'],
                                                      comediansArray[arrayIndex]['endTime'],
                                                      comediansArray[arrayIndex]['facebook'],
                                                      comediansArray[arrayIndex]['instagram'],
                                                      comediansArray[arrayIndex]['twitter'],
                                                      comediansArray[arrayIndex]['snapchat'],
                                                    );
                                                  },
                                                ),
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
                const SizedBox(height: 5.0),

                // Button to navigate to the CreateComedian Widget
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 0.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      maximumSize: const Size(200, 50),
                      primary:
                      const Color.fromRGBO(22, 66, 139, 1),
                    ),
                    child: const Text('Create Comedian'),

                    // When tapped, navigate to the CreateComedian Widget
                    onPressed: () async {
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => const CreateComedian(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            );
          }),
    );
  }
}

// The delete comedian confirmation pop-up Widget
showDeleteAlertDialog(
    context,
    id,
    name,
    startTime,
    endTime,
    facebook,
    instagram,
    twitter,
    snapchat
    ) {

  final DatabaseService _database = DatabaseService();

  // If the user taps "Yes", delete the comedian from the ComedyNightSchedule
  // document's comedians array
  // Then close the pop-up
  Widget yesButton = TextButton(
    child: const Text("Yes"),
    onPressed: () async {
      await _database.deleteComedian(
        id,
        name,
        startTime,
        endTime,
        facebook,
        instagram,
        twitter,
        snapchat
      );
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
        "Are you sure you want to delete this comedian?"),
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