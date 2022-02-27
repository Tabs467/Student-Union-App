import 'package:cloud_firestore/cloud_firestore.dart';

// Model for the Comedy Night Schedule
class ComedyNightSchedule {

  String? id;
  Timestamp? date;
  List<dynamic>? comedians = [];

  ComedyNightSchedule({this.id, this.date, this.comedians});

}