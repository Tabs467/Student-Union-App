import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a Comedian in the Comedy Night Schedule
class Comedian {

  String? id;
  String? name;
  Timestamp? startTime;
  Timestamp? endTime;
  String? facebook;
  String? instagram;
  String? twitter;
  String? snapchat;

  Comedian({
    this.id,
    this.name,
    this.startTime,
    this.endTime,
    this.facebook,
    this.instagram,
    this.twitter,
    this.snapchat
  });

}