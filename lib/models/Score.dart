// Model for a user's score in a quiz
class Score {

  String? id;
  bool? currentQuestionCorrect;
  String? quizID;
  String? userID;
  int? score;
  dynamic currentQuestionAnswer;

  Score({
    this.id,
    this.currentQuestionCorrect,
    this.quizID,
    this.userID,
    this.score,
    this.currentQuestionAnswer
  });

}