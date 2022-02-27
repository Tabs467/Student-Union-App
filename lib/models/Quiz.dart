import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a quiz in the pub quiz
class Quiz {

  String? id;
  String? quizTitle;
  bool? quizEnded;
  int? questionCount;
  bool? isActive;
  int? currentQuestion;
  Timestamp? creationDate;

  Quiz({
    this.id,
    this.quizTitle,
    this.quizEnded,
    this.questionCount,
    this.isActive,
    this.currentQuestion,
    this.creationDate
  });

}