// Model for a question in a quiz
class Question {

  String? id;
  dynamic correctAnswer;
  int? questionNumber;
  String? questionText;
  String? quizID;
  String? questionType;

  Question({
    this.id,
    this.correctAnswer,
    this.questionNumber,
    this.questionText,
    this.quizID,
    this.questionType
  });

}