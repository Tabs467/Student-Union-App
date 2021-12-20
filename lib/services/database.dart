import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:student_union_app/models/Question.dart';

class DatabaseService {

  CollectionReference quizCollection = FirebaseFirestore.instance.collection('Quizzes');
  CollectionReference questionCollection = FirebaseFirestore.instance.collection('Questions');

  // Insert a question into the Questions collection in the database
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

  // Not currently using the Question Model
  /**
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
  }*/

  // Mark the inputted quiz as active and set the non active quiz marker in the
  // database to false
  Future startQuiz(String quizID) async {
    // Mark the Quiz document that is used to mark that there
    // isn't a quiz currently active as inactive
    quizCollection.doc('cy7RWIJ3VGIXlHSM1Il8').update({"isActive" : false});

    // Mark the inputted quiz document as active
    return quizCollection.doc(quizID).update({"isActive" : true, "quizEnded" : false});
  }

  // Mark the inputted quiz as inactive and set the non active quiz marker in the
  // database to true
  Future endQuiz(String quizID) async {
    // Mark the Quiz document that is used to mark that there
    // isn't a quiz currently active as active
    quizCollection.doc('cy7RWIJ3VGIXlHSM1Il8').update({"isActive" : true});

    // Mark the inputted quiz document as inactive
    return quizCollection.doc(quizID).update({"isActive" : false, "quizEnded" : true, "currentQuestion" : 1});
  }

  // Move an inputted quiz to its next question and mark whether the quiz has ended or not
  Future nextQuestion(String quizID, int currentQuestionNumber, int questionCount) async {
    currentQuestionNumber++;

    // If the previous question was the last question in the quiz
    if (currentQuestionNumber > questionCount) {
      // Also mark the quiz as ended in the database
      return quizCollection.doc(quizID).update({"currentQuestion" : currentQuestionNumber, "quizEnded" : true});
    }
    // Otherwise
    else {
      // Just increment the current question number variable on the inputted Quiz Document
      return quizCollection.doc(quizID).update({"currentQuestion" : currentQuestionNumber});
    }
  }
}
