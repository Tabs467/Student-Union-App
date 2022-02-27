import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/models/Comedian.dart';
import 'package:student_union_app/screens/buildAppBar.dart';
import 'package:student_union_app/screens/buildTabTitle.dart';
import 'package:student_union_app/services/database.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class EditComedian extends StatefulWidget {
  final Comedian comedian;

  const EditComedian(
      {Key? key,
        required this.comedian,
      })
      : super(key: key);

  @override
  _EditComedianState createState() => _EditComedianState();
}

// Widget to display the Edit Comedian form
class _EditComedianState extends State<EditComedian> {
  final DatabaseService _database = DatabaseService();

  final _formKey = GlobalKey<FormState>();

  // Form field state
  String comedianID = '';
  String comedianName = '';
  DateTime startDateTime = DateTime.now();
  DateTime endDateTime = DateTime.now();
  String facebook = '';
  String instagram = '';
  String twitter = '';
  String snapchat = '';
  String error = '';


  // Retrieve the comedian's details from the parameters passed to the Widget
  // and prepare them for display
  @override
  void initState() {

    Comedian comedian = widget.comedian;

    comedianID = comedian.id!;
    comedianName = comedian.name!;

    // Convert the passed Timestamps to DateTime objects
    startDateTime = comedian.startTime!.toDate();
    endDateTime = comedian.endTime!.toDate();

    // If a social media link has not been set just display an empty string
    // rather than the "Not Set" string
    if (comedian.facebook == "Not Set") {
      facebook = '';
    }
    else {
      // Substring to remove the extra characters at the start of the link
      // that allows it to be opened in the Facebook app
      // As the user does not type these in
      facebook = comedian.facebook!.substring(25);
    }

    if (comedian.twitter == "Not Set") {
      twitter = '';
    }
    else {
      twitter = comedian.twitter!;
    }

    if (comedian.instagram == "Not Set") {
      instagram = '';
    }
    else {
      instagram = comedian.instagram!;
    }

    if (comedian.snapchat == "Not Set") {
      snapchat = '';
    }
    else {
      snapchat = comedian.snapchat!;
    }
    super.initState();
  }


  // Returns true if the time inputted is after the startDateTime form state
  bool _isEndTimeAfterStartTime(DateTime endTime) {

    // Since only hours and minutes are being compared the startDateTime's year,
    // month, day, milliseconds and microseconds are used with the endTime
    DateTime endTimeWithDate = DateTime(
        startDateTime.year, startDateTime.month, startDateTime.day,
        endTime.hour, endTime.minute, startDateTime.second,
        startDateTime.millisecond, startDateTime.microsecond
    );

    return endTimeWithDate.isAfter(startDateTime);
  }


  // Check whether the start of an inputted Facebook profile link has been
  // entered in the correct format
  bool _checkFacebook(String facebookLink) {
    String linkSubstring = 'https://www.facebook.com/';

    if (facebookLink.length > 25) {
      if (facebookLink.substring(0, 25) == linkSubstring) {
        return true;
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }


  // Check whether the start of an inputted Instagram profile link has been
  // entered in the correct format
  bool _checkInstagram(String instagramLink) {
    String linkSubstring = 'https://www.instagram.com/';

    if (instagramLink.length > 26) {
      if (instagramLink.substring(0, 26) == linkSubstring) {
        return true;
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }


  // Check whether the start of an inputted Twitter profile link has been
  // entered in the correct format
  bool _checkTwitter(String twitterLink) {
    String linkSubstring = 'https://twitter.com/';

    if (twitterLink.length > 20) {
      if (twitterLink.substring(0, 20) == linkSubstring) {
        return true;
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }


  // Check whether the start of an inputted Snapchat share link has been
  // entered in the correct format
  bool _checkSnapchat(String snapchatLink) {
    String linkSubstring = 'https://www.snapchat.com/add/';

    if (snapchatLink.length > 29) {
      if (snapchatLink.substring(0, 29) == linkSubstring) {
        return true;
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'Comedy'),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
              child: buildTabTitle('Edit Comedian', 35),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 30.0),

              // Initial values of the form fields are the parameters passed to
              // this Widget
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: comedianName,
                      decoration: const InputDecoration(
                        hintText: 'Comedian Name',
                      ),
                      // Comedian Name cannot be empty and must be
                      // below 70 characters
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return "Comedian Name cannot be empty!";
                        } else if (value!.length > 70) {
                          return "Comedian Name must be below 70 characters!";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          comedianName = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Start Time:',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    DateTimeField(
                      format: DateFormat("HH:mm"),

                      initialValue: startDateTime,

                      // Start time cannot be empty
                      validator: (DateTime? value) {
                        if (value == null) {
                          return "Start Time cannot be empty!";
                        }
                        return null;
                      },

                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                        );

                        // If a time is selected save it in the form field state
                        if (time != null) {
                          startDateTime = DateTimeField.convert(time)!;
                        }

                        return DateTimeField.convert(time);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'End Time:',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    DateTimeField(
                      format: DateFormat("HH:mm"),

                      initialValue: endDateTime,

                      // End Time cannot be empty and must occur after the
                      // Start Time
                      validator: (DateTime? value) {
                        if (value == null) {
                          return "End Time cannot be empty!";
                        } else if (startDateTime != null
                            && !_isEndTimeAfterStartTime(endDateTime)) {
                          return "End Time must be after Start Time!";
                        }
                        return null;
                      },

                      onShowPicker: (context, currentValue) async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                        );

                        // If a time is selected save it in the form field state
                        if (time != null) {
                          endDateTime = DateTimeField.convert(time)!;
                        }

                        return DateTimeField.convert(time);
                      },
                    ),
                    const SizedBox(height: 50.0),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                          'Acceptable Format:\nhttps://www.facebook.com/comedianProfile'
                      ),
                    ),
                    TextFormField(
                      initialValue: facebook,
                      decoration: const InputDecoration(
                        hintText: 'Facebook Profile Link',
                      ),
                      // Profile Link must be in the form:
                      // https://www.facebook.com/comedianProfile
                      // But can be left empty
                      validator: (String? value) {
                        if (value != null && value != '' && !_checkFacebook(value)) {
                          return "Acceptable Format Example:\nhttps://www.facebook.com/zuck";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          facebook = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                          'Acceptable Format:\nhttps://www.instagram.com/comedianProfile'
                      ),
                    ),
                    TextFormField(
                      initialValue: instagram,
                      decoration: const InputDecoration(
                        hintText: 'Instagram Profile Link',
                      ),
                      // Profile Link must be in the form:
                      // https://www.instagram.com/comedianProfile
                      // But can be left empty
                      validator: (String? value) {
                        if (value != null && value != '' && !_checkInstagram(value)) {
                          return "Acceptable Format Example:\nhttps://www.instagram.com/zuck";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          instagram = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Acceptable Format:\nhttps://twitter.com/comedianProfile',
                      ),
                    ),
                    TextFormField(
                      initialValue: twitter,
                      decoration: const InputDecoration(
                        hintText: 'Twitter Profile Link',
                      ),
                      // Profile Link must be in the form:
                      // https://twitter.com/comedianProfile
                      // But can be left empty
                      validator: (String? value) {
                        if (value != null && value != '' && !_checkTwitter(value)) {
                          return "Acceptable Format Example:\nhttps://twitter.com/twitter";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          twitter = val;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                          'Acceptable Format:\nhttps://www.snapchat.com/add/profileShareLink'
                      ),
                    ),
                    TextFormField(
                      initialValue: snapchat,
                      decoration: const InputDecoration(
                        hintText: 'Snapchat Profile Link',
                      ),
                      // Profile Link must be in the form:
                      // https://www.snapchat.com/add/profileShareLink
                      // But can be left empty
                      validator: (String? value) {
                        if (value != null && value != '' && !_checkSnapchat(value)) {
                          return "Acceptable Format Example:\nhttps://www.snapchat.com/add/userName?share_id=foihrghu5h7&locale=en-GB";
                        }
                        return null;
                      },
                      onChanged: (val) {
                        setState(() {
                          snapchat = val;
                        });
                      },
                    ),
                    const SizedBox(height: 6.0),
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

                      // When the Submit Changes button is tapped, validate
                      // each field in the form, prepare the social media links
                      // for storage, convert the DateTimes to Timestamps,
                      // and update the comedian in the comedians array in the
                      // database
                      // Then return the user to the ComedyNightAdmin Widget
                      // once the comedian is added to the database
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {

                          // Prepare social media links for storage
                          // If they have been left empty store them as
                          // 'Not Set'
                          if (facebook == '') {
                            facebook = "Not Set";
                          }
                          // Extra string appended onto the front of the
                          // facebook link so that it is opened with the
                          // facebook app
                          else {
                            facebook = "fb://facewebmodal/f?href=" + facebook;
                          }
                          if (instagram == '') {
                            instagram = "Not Set";
                          }
                          if (twitter == '') {
                            twitter = "Not Set";
                          }
                          if (snapchat == '') {
                            snapchat = "Not Set";
                          }


                          // Convert the DateTimes to Timestamps as they are
                          // stored as Timestamps in the database
                          Timestamp startTimeStamp = Timestamp.fromDate(startDateTime);
                          Timestamp endTimeStamp = Timestamp.fromDate(endDateTime);

                          Comedian comedian = Comedian(
                              id: comedianID,
                              name: comedianName,
                              startTime: startTimeStamp,
                              endTime: endTimeStamp,
                              facebook: facebook,
                              instagram: instagram,
                              twitter: twitter,
                              snapchat: snapchat
                          );

                          // Update the comedian in the comedians array in the
                          // ComedyNightSchedule document
                          await _database.editComedian(comedian);

                          // Return the user to the ComedyNightAdmin Widget
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
              child: const Text('Return'),
              // Return the user back to the ComedyNightAdmin Widget
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
