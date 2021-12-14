import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future startQuiz(String quizID) async {
    quizActive = true;

    return quizCollection.doc(quizID).update({"isActive" : true});
  }

  Future endQuiz(String quizID) async {
    quizActive = false;

    return quizCollection.doc(quizID).update({"isActive" : false});
  }

  /**Future retrieveQuestion(String quizID, int questionNumber) async {
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
  }**/
}
