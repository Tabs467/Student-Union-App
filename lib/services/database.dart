import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {


  // collection reference
  CollectionReference questionCollection = FirebaseFirestore.instance.collection('Questions');


  Future createQuestion(String quizID, int questionNumber, String questionText, String answerA, String answerB, String answerC, String answerD) async {
    // If document with questionID does not already exist it will be created
    return await questionCollection.doc().set({
      'quizID': quizID,
      'questionNumber' : questionNumber,
      'questionText' : questionText,
      'answerA' : answerA,
      'answerB' : answerB,
      'answerC' : answerC,
      'answerD' : answerD,
    });
  }

  Future retrieveQuestion(String quizID, int questionNumber) async {
    // If document with questionID does not already exist it will be created
    return await questionCollection.doc().set({
      'quizID': quizID,
      'questionNumber' : questionNumber,
      'questionText' : questionText,
      'answerA' : answerA,
      'answerB' : answerB,
      'answerC' : answerC,
      'answerD' : answerD,
    });
  }
}
