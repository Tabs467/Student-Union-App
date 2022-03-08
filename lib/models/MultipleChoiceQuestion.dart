import 'Question.dart';

// Model for a multiple choice question in a quiz
class MultipleChoiceQuestion extends Question {

  String? answerA;
  String? answerB;
  String? answerC;
  String? answerD;

  MultipleChoiceQuestion(
      {id,
      correctAnswer,
      questionNumber,
      questionText,
      quizID,
      this.answerA,
      this.answerB,
      this.answerC,
      this.answerD})
      : super(
            id: id,
            correctAnswer: correctAnswer,
            questionNumber: questionNumber,
            questionText: questionText,
            quizID: quizID,
            questionType: 'MCQ');

}
