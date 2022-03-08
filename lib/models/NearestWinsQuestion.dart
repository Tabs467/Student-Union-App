import 'Question.dart';

// Model for a nearest wins question in a quiz
class NearestWinsQuestion extends Question {

  NearestWinsQuestion({id, correctAnswer, questionNumber, questionText, quizID})
      : super(
            id: id,
            correctAnswer: correctAnswer,
            questionNumber: questionNumber,
            questionText: questionText,
            quizID: quizID,
            questionType: 'NWQ');

}
