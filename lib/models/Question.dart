// Model for a question in a quiz
class Question {

  String? id;
  String? answerA;
  String? answerB;
  String? answerC;
  String? answerD;
  String? correctAnswer;
  int? questionNumber;
  String? questionText;
  String? quizID;

  Question({
    this.id,
    this.answerA,
    this.answerB,
    this.answerC,
    this.answerD,
    this.correctAnswer,
    this.questionNumber,
    this.questionText,
    this.quizID
  });

}