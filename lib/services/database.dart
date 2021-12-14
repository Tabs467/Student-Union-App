import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_union_app/models/Question.dart';

class DatabaseService {

  CollectionReference quizCollection = FirebaseFirestore.instance.collection('Quizzes');
  CollectionReference questionCollection = FirebaseFirestore.instance.collection('Questions');

  bool quizActive = false;

  isQuizActive() {
    return quizActive;
  }

  Future createQuestion(String quizID, int questionNumber, String questionText, String correctAnswer, String answerA, String answerB, String answerC, String answerD) async {
    // If document with questionID does not already exist it will be created
    return await questionCollection.doc().set({
      'quizID': quizID,
      'questionNumber' : questionNumber,
      'questionText' : questionText,
      'correctAnswer' : correctAnswer,
      'answerA' : answerA,
      'answerB' : answerB,
      'answerC' : answerC,
      'answerD' : answerD,
    });
  }



  Stream<QuerySnapshot> get quizzes {
    return quizCollection.snapshots();
  }

  Stream<QuerySnapshot> get questions {
    return questionCollection.snapshots();
  }

  /**int questionNumberFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return doc.get('currentQuestion') ?? -1;
    }).toList();
  }*/

  List <Question> questionDetailsFromSnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return Question(
          questionID: 'Do we need this?',
          quizID: 'Do we need this?',
          questionText: doc.get('questionText') ?? '',
          questionNumber: doc.get('questionNumber') ?? -1,
          correctAnswer: doc.get('correctAnswer') ?? '',
          answerA: doc.get('answerA') ?? '',
          answerB: doc.get('answerB') ?? '',
          answerC: doc.get('answerC') ?? '',
          answerD: doc.get('answerD') ?? '',
      );
    }).toList();
  }

  retrieveCurrentQuestion(String quizID) async {



      return;

      //return quizCollection.doc(quizID).get().data();

      // get current question number of quiz from quizID and quiz table
      AsyncSnapshot<DocumentSnapshot> snapshot = questionCollection.doc(quizID).get() as AsyncSnapshot<DocumentSnapshot<Object?>>;

      Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
      debugPrint(data.toString());
      return data;

      // get current question data from retrieved question number and quiz id

      // return question
      //return Question();
  }

  Future startQuiz(String quizID) async {
    quizActive = true;

    return quizCollection.doc(quizID).update({"isActive" : true, "quizEnded" : false});
  }

  Future endQuiz(String quizID) async {
    quizActive = false;

    return quizCollection.doc(quizID).update({"isActive" : false, "quizEnded" : true, "currentQuestion" : 1});
  }

  Future nextQuestion(String quizID, int currentQuestionNumber, int questionCount) async {
    currentQuestionNumber++;

    if (currentQuestionNumber > questionCount) {
      return quizCollection.doc(quizID).update({"currentQuestion" : currentQuestionNumber, "quizEnded" : true});
    }
    else {
      return quizCollection.doc(quizID).update({"currentQuestion" : currentQuestionNumber});
    }
  }
}
