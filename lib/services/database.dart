import 'package:student_union_app/models/BandaokeQueue.dart';
import 'package:student_union_app/models/Comedian.dart';
import 'package:student_union_app/models/ComedyNightSchedule.dart';
import 'package:student_union_app/models/LeaderboardEntry.dart';
import 'package:student_union_app/models/MenuGroup.dart';
import 'package:student_union_app/models/MenuSubGroup.dart';
import 'package:student_union_app/models/MonthlyLeaderboardDoc.dart';
import 'package:student_union_app/models/MultipleChoiceQuestion.dart';
import 'package:student_union_app/models/NearestWinsQuestion.dart';
import 'package:student_union_app/models/Question.dart';
import 'package:student_union_app/models/Quiz.dart';
import 'package:student_union_app/models/Score.dart';
import 'package:student_union_app/models/SemesterlyLeaderboardDoc.dart';
import 'package:student_union_app/models/YearlyLeaderboardDoc.dart';
import 'authentication.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_union_app/models/CurrentUser.dart';

// Database Service class to provide Google FireStore data and services
// to the Views
class DatabaseService {

  // Google FireStore collection references
  CollectionReference quizCollection =
      FirebaseFirestore.instance.collection('Quizzes');
  CollectionReference questionCollection =
      FirebaseFirestore.instance.collection('Questions');
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');
  CollectionReference scoreCollection =
      FirebaseFirestore.instance.collection('Scores');
  CollectionReference menuGroupCollection =
      FirebaseFirestore.instance.collection('MenuGroup');
  CollectionReference menuSubGroupCollection =
      FirebaseFirestore.instance.collection('MenuSubGroup');
  CollectionReference bandaokeQueueCollection =
      FirebaseFirestore.instance.collection('BandaokeQueue');
  CollectionReference comedyNightScheduleCollection =
      FirebaseFirestore.instance.collection('ComedyNightSchedule');
  CollectionReference monthlyLeaderboardEntriesCollection =
      FirebaseFirestore.instance.collection('MonthlyLeaderboardEntries');
  CollectionReference semesterlyLeaderboardEntriesCollection =
      FirebaseFirestore.instance.collection('SemesterlyLeaderboardEntries');
  CollectionReference yearlyLeaderboardEntriesCollection =
      FirebaseFirestore.instance.collection('YearlyLeaderboardEntries');

  // Some FireStore access requires the authentication service to determine
  // the currently logged-in user's UID
  final AuthenticationService _auth = AuthenticationService();


  // Return a stream of the MenuGroups
  Stream<QuerySnapshot> getMenuGroups() {
    return menuGroupCollection.snapshots();
  }


  // Return a stream of the MenuSubGroups inside of a MenuGroup
  Stream<QuerySnapshot> getMenuSubGroups(String selectedMenuGroupID) {
    return menuSubGroupCollection
        .where('MenuGroupID', isEqualTo: selectedMenuGroupID)
        .snapshots();
  }


  // Return a stream of the selected MenuSubGroup
  Stream<QuerySnapshot> getMenuSubGroup(String selectedSubGroupID) {
    return menuSubGroupCollection
        .where('id', isEqualTo: selectedSubGroupID)
        .snapshots();
  }


  // Return a stream of the currently active quiz
  Stream<QuerySnapshot> getActiveQuiz() {
    return quizCollection.where('isActive', isEqualTo: true).snapshots();
  }


  // Return a stream of the currently active question in the pub quiz
  Stream<QuerySnapshot> getCurrentQuestion(
      String quizID, int questionNumber
      ) {

    return questionCollection
        .where('quizID', isEqualTo: quizID)
        .where('questionNumber', isEqualTo: questionNumber)
        .snapshots();
  }


  // Return a stream of all the score documents for a given quiz in order of
  // descending score
  Stream<QuerySnapshot> getLeaderboardScores(String quizID) {

    return scoreCollection
        .orderBy('score', descending: true)
        .where('quizID', isEqualTo: quizID)
        .snapshots();
  }


  // Return a stream of all the quiz documents inside the Quizzes collection
  // ordered by the most recent creationDate
  Stream<QuerySnapshot> getOrderedQuizzes() {
    return quizCollection.orderBy('creationDate', descending: true).snapshots();
  }


  // Return a stream of the questions inside of a quiz ordered by
  // ascending question numbers
  Stream<QuerySnapshot> getOrderedQuestions(String quizID) {
    return questionCollection
        .where('quizID', isEqualTo: quizID)
        .orderBy('questionNumber')
        .snapshots();
  }


  // Return a stream containing the snapshots of the bandaoke queue
  Stream<QuerySnapshot> getBandaokeQueue() {
    return bandaokeQueueCollection
        .where('id', isEqualTo: 'Z4NtbE7IQ2vp32WHkpYY')
        .snapshots();
  }


  // Return a stream containing the snapshots of the comedy night schedule
  Stream<QuerySnapshot> getComedyNightSchedule() {
    return comedyNightScheduleCollection.snapshots();
  }


  // Return a stream containing the snapshots of the singleton monthly
  // leaderboard document
  Stream<QuerySnapshot> getMonthlyLeaderboardDoc() {
    return monthlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'AoJjjYhtjLeYQhc2s8zK')
        .snapshots();
  }


  // Return a stream of all the leaderboard entries for a given month in order
  // of descending total wins
  Stream<QuerySnapshot> getMonthlyScores(int seasonNumber) {

    return monthlyLeaderboardEntriesCollection
        .orderBy('totalWins', descending: true)
        .where('seasonNumber', isEqualTo: seasonNumber)
        .snapshots();
  }


  // Return a stream containing the snapshots of the singleton semesterly
  // leaderboard document
  Stream<QuerySnapshot> getSemesterlyLeaderboardDoc() {
    return semesterlyLeaderboardEntriesCollection
        .where('id', isEqualTo: '2RpLeBNHCgOcHzjORDCQ')
        .snapshots();
  }


  // Return a stream of all the leaderboard entries for a given semester in
  // order of descending total wins
  Stream<QuerySnapshot> getSemesterlyScores(int seasonNumber) {

    return semesterlyLeaderboardEntriesCollection
        .orderBy('totalWins', descending: true)
        .where('seasonNumber', isEqualTo: seasonNumber)
        .snapshots();
  }


  // Return a stream containing the snapshots of the singleton yearly
  // leaderboard document
  Stream<QuerySnapshot> getYearlyLeaderboardDoc() {
    return yearlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'OrAMZAbg8wi3UTUgcYth')
        .snapshots();
  }


  // Return a stream of all the leaderboard entries for a given year in order
  // of descending total wins
  Stream<QuerySnapshot> getYearlyScores(int seasonNumber) {

    return yearlyLeaderboardEntriesCollection
        .orderBy('totalWins', descending: true)
        .where('seasonNumber', isEqualTo: seasonNumber)
        .snapshots();
  }


  // Create or update user information into the Users collection
  // in the database
  Future updateUser(String uid, String name, String teamName,
      int wins, int monthlyWins, int semesterlyWins, int yearlyWins,
      var winDates, var monthlyWinDates, var semesterlyWinDates,
      var yearlyWinDates, bool admin) async {

    // If a document with the given uid doesn't exist yet in the database
    // it will be created
    return await userCollection.doc(uid).set({
      'uid': uid,
      'name': name,
      'teamName': teamName,
      'wins': wins,
      'monthlyWins': monthlyWins,
      'semesterlyWins': semesterlyWins,
      'yearlyWins': yearlyWins,
      'winDates': winDates,
      'monthlyWinDates': monthlyWinDates,
      'semesterlyWinDates': semesterlyWinDates,
      'yearlyWinDates': yearlyWinDates,
      'admin': admin,
    });
  }


  // Create a CurrentUser object based on results from a query to the
  // Users collection
  CurrentUser? _userFromQuery(String uid, String email, String name,
      String teamName, int wins, int monthlyWins, int semesterlyWins,
      int yearlyWins, var winDates, var monthlyWinDates, var semesterlyWinDates,
      var yearlyWinDates, bool admin) {

    return CurrentUser(
        uid: uid,
        email: email,
        name: name,
        teamName: teamName,
        wins: wins,
        monthlyWins: monthlyWins,
        semesterlyWins: semesterlyWins,
        yearlyWins: yearlyWins,
        winDates: winDates,
        monthlyWinDates: monthlyWinDates,
        semesterlyWinDates: semesterlyWinDates,
        yearlyWinDates: yearlyWinDates,
        admin: admin);
  }


  // Query to return the logged-in user's data
  Future getLoggedInUserData() async {
    String uid = _auth.currentUID()!;
    String email = _auth.currentEmail()!;
    String name = '';
    String teamName = '';
    int wins = 0;
    int monthlyWins = 0;
    int semesterlyWins = 0;
    int yearlyWins = 0;
    var winDates = [];
    var monthlyWinDates = [];
    var semesterlyWinDates = [];
    var yearlyWinDates = [];
    bool admin = false;

    await userCollection
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                name = doc["name"];
                teamName = doc["teamName"];
                wins = doc["wins"];
                monthlyWins = doc["monthlyWins"];
                semesterlyWins = doc["semesterlyWins"];
                yearlyWins = doc["yearlyWins"];
                winDates = doc["winDates"];
                monthlyWinDates = doc["monthlyWinDates"];
                semesterlyWinDates = doc["semesterlyWinDates"];
                yearlyWinDates = doc["yearlyWinDates"];
                admin = doc["admin"];
              })
            });

    return _userFromQuery(uid, email, name, teamName, wins, monthlyWins,
        semesterlyWins, yearlyWins, winDates, monthlyWinDates,
        semesterlyWinDates, yearlyWinDates, admin);
  }


  // Query to return a user's data
  Future getUserData(uid) async {
    // No reason to return a non-currently logged-in user's email for security
    // purposes
    String email = 'Private';

    String name = '';
    String teamName = '';
    int wins = 0;
    int monthlyWins = 0;
    int semesterlyWins = 0;
    int yearlyWins = 0;
    var winDates = [];
    var monthlyWinDates = [];
    var semesterlyWinDates = [];
    var yearlyWinDates = [];
    bool admin = false;

    await userCollection
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        name = doc["name"];
        teamName = doc["teamName"];
        wins = doc["wins"];
        monthlyWins = doc["monthlyWins"];
        semesterlyWins = doc["semesterlyWins"];
        yearlyWins = doc["yearlyWins"];
        winDates = doc["winDates"];
        monthlyWinDates = doc["monthlyWinDates"];
        semesterlyWinDates = doc["semesterlyWinDates"];
        yearlyWinDates = doc["yearlyWinDates"];
        admin = doc["admin"];
      })
    });

    return _userFromQuery(uid, email, name, teamName, wins, monthlyWins,
        semesterlyWins, yearlyWins, winDates, monthlyWinDates,
        semesterlyWinDates, yearlyWinDates, admin);
  }


  // Check if the currently logged-in user is an admin
  Future<bool> userAdmin() async {
    bool admin = false;

    if (_auth.currentUID() != null) {
      String uid = _auth.currentUID()!;

      await userCollection
          .where('uid', isEqualTo: uid)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  admin = doc["admin"];
                })
              });
    }

    return admin;
  }


  // Update the currently logged-in user's Name and Team Name
  Future updateUserNameDetails(name, teamName) async {
    String uid = _auth.currentUID()!;
    return userCollection.doc(uid).update({"name": name, "teamName": teamName});
  }


  // Update the currently logged-in user's Team Name
  Future updateUserTeamNameDetails(teamName) async {
    String uid = _auth.currentUID()!;
    return userCollection.doc(uid).update({"teamName": teamName});
  }


  // Update a user's number of pub quiz wins to include one more win
  // And add the win date to their document
  // And add one more win and to the total points to their current monthly,
  // semesterly, and yearly total wins of the current seasons
  Future addWin(String uid, int points) async {
    // Retrieve the given user's data
    CurrentUser winningUser = await getUserData(uid) as CurrentUser;

    // Calculate the new amount of wins
    int newWins = winningUser.wins + 1;

    // Update the user document to store the new number of wins
    // And the new win date
    await userCollection.doc(uid).update({
      'wins': newWins,
      'winDates': FieldValue.arrayUnion([DateTime.now()])
    });



    // Retrieve the current monthly season number
    int monthlySeason = await retrieveCurrentMonthlySeason();

    String monthlyEntryID = '';
    int totalPoints = -1;
    int totalWins = -1;
    bool monthlyRecordFound = false;

    // Attempt to retrieve the user's existing monthly leaderboard entry for the
    // current season
    await monthlyLeaderboardEntriesCollection
        .where('userID', isEqualTo: uid)
        .where('seasonNumber', isEqualTo: monthlySeason)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        LeaderboardEntry entry = leaderboardEntryFromSnapshot(doc);

        monthlyEntryID = entry.id!;
        totalPoints = entry.totalPoints!;
        totalWins = entry.totalWins!;

        monthlyRecordFound = true;
      })
    });

    // If a leaderboard entry for the current season could be found
    // Update the existing record
    if (monthlyRecordFound) {
      // Update the user's Monthly Leaderboard Entry document to include one more
      // win and the points gained (if one doesn't exist it will be created)
      await monthlyLeaderboardEntriesCollection.doc(monthlyEntryID).update({
        'totalWins': (totalWins + 1),
        'totalPoints': (totalPoints + points)
      });
    }
    // Otherwise, create a new record
    else {
      String newMonthlyEntryID = _generateID();
      await monthlyLeaderboardEntriesCollection.doc(newMonthlyEntryID).set({
        'id': newMonthlyEntryID,
        'seasonNumber': monthlySeason,
        'totalWins': 1,
        'totalPoints': points,
        'userID': uid
      });
    }



    // Retrieve the current semesterly season number
    int semesterlySeason = await retrieveCurrentSemesterlySeason();

    String semesterlyEntryID = '';
    totalPoints = -1;
    totalWins = -1;
    bool semesterlyRecordFound = false;

    // Attempt to retrieve the user's existing semesterly leaderboard entry for
    // the current season
    await semesterlyLeaderboardEntriesCollection
        .where('userID', isEqualTo: uid)
        .where('seasonNumber', isEqualTo: semesterlySeason)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        LeaderboardEntry entry = leaderboardEntryFromSnapshot(doc);

        semesterlyEntryID = entry.id!;
        totalPoints = entry.totalPoints!;
        totalWins = entry.totalWins!;

        semesterlyRecordFound = true;
      })
    });

    // If a leaderboard entry for the current season could be found
    // Update the existing record
    if (semesterlyRecordFound) {
      // Update the user's Semesterly Leaderboard Entry document to include one
      // more win and the points gained (if one doesn't exist it will be created)
      await semesterlyLeaderboardEntriesCollection.doc(semesterlyEntryID).update({
        'totalWins': (totalWins + 1),
        'totalPoints': (totalPoints + points)
      });
    }
    // Otherwise, create a new record
    else {
      String newSemesterlyEntryID = _generateID();
      await semesterlyLeaderboardEntriesCollection.doc(newSemesterlyEntryID).set({
        'id': newSemesterlyEntryID,
        'seasonNumber': semesterlySeason,
        'totalWins': 1,
        'totalPoints': points,
        'userID': uid
      });
    }



    // Retrieve the current yearly season number
    int yearlySeason = await retrieveCurrentYearlySeason();

    String yearlyEntryID = '';
    totalPoints = -1;
    totalWins = -1;
    bool yearlyRecordFound = false;

    // Attempt to retrieve the user's existing yearly leaderboard entry for the
    // current season
    await yearlyLeaderboardEntriesCollection
        .where('userID', isEqualTo: uid)
        .where('seasonNumber', isEqualTo: yearlySeason)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        LeaderboardEntry entry = leaderboardEntryFromSnapshot(doc);

        yearlyEntryID = entry.id!;
        totalPoints = entry.totalPoints!;
        totalWins = entry.totalWins!;

        yearlyRecordFound = true;
      })
    });

    // If a leaderboard entry for the current season could be found
    // Update the existing record
    if (yearlyRecordFound) {
      // Update the user's Yearly Leaderboard Entry document to include one more
      // win and the points gained (if one doesn't exist it will be created)
      await yearlyLeaderboardEntriesCollection.doc(yearlyEntryID).update({
        'totalWins': (totalWins + 1),
        'totalPoints': (totalPoints + points)
      });
    }
    // Otherwise, create a new record
    else {
      String newYearlyEntryID = _generateID();
      await yearlyLeaderboardEntriesCollection.doc(newYearlyEntryID).set({
        'id': newYearlyEntryID,
        'seasonNumber': yearlySeason,
        'totalWins': 1,
        'totalPoints': points,
        'userID': uid
      });
    }
  }


  // Generate id by creating a String from generating 20 random numbers
  // which correspond to characters in the _chars constant
  String _generateID() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return String.fromCharCodes(Iterable.generate(
        20, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
  }


  // Return a Question Model object from a given Question snapshot
  Question questionFromSnapshot(var snapshotList) {
      return Question(
        id: snapshotList['id'],
        correctAnswer: snapshotList['correctAnswer'],
        questionNumber: snapshotList['questionNumber'],
        questionText: snapshotList['questionText'],
        quizID: snapshotList['quizID'],
        questionType: snapshotList['questionType']
      );
  }


  // Return a Multiple Choice Question Model object from a given Question snapshot
  MultipleChoiceQuestion multipleChoiceQuestionFromSnapshot(var snapshotList) {
      return MultipleChoiceQuestion(
        id: snapshotList['id'],
        answerA: snapshotList['answerA'],
        answerB: snapshotList['answerB'],
        answerC: snapshotList['answerC'],
        answerD: snapshotList['answerD'],
        correctAnswer: snapshotList['correctAnswer'],
        questionNumber: snapshotList['questionNumber'],
        questionText: snapshotList['questionText'],
        quizID: snapshotList['quizID'],
      );
  }


  // Return a Nearest Wins Question Model object from a given Question snapshot
  NearestWinsQuestion nearestWinsQuestionFromSnapshot(var snapshotList) {
    return NearestWinsQuestion(
      id: snapshotList['id'],
      correctAnswer: snapshotList['correctAnswer'],
      questionNumber: snapshotList['questionNumber'],
      questionText: snapshotList['questionText'],
      quizID: snapshotList['quizID'],
    );
  }


  // Insert a new multiple choice question document into the Questions collection
  // Whilst also incrementing the total number of questions contained within
  // the new question's quiz
  Future createMultipleChoiceQuestion(MultipleChoiceQuestion question) async {

    String id = _generateID();

    // Increment total questions in the new questions' quiz by one
    await quizCollection
        .where('id', isEqualTo: question.quizID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        Quiz quiz = quizFromSnapshot(doc);

        int totalQuestions = quiz.questionCount!;

        await quizCollection.doc(question.quizID).update({
          "questionCount": (totalQuestions + 1),
        });
      })
    });

    // Create the question document
    return await questionCollection.doc(id).set({
      'id': id,
      'quizID': question.quizID,
      'questionNumber': question.questionNumber,
      'questionText': question.questionText,
      'correctAnswer': question.correctAnswer,
      'answerA': question.answerA,
      'answerB': question.answerB,
      'answerC': question.answerC,
      'answerD': question.answerD,
      'questionType': 'MCQ'
    });
  }


  // Insert a new nearest wins question document into the Questions collection
  // Whilst also incrementing the total number of questions contained within
  // the new question's quiz
  Future createNearestWinsQuestion(NearestWinsQuestion question) async {

    String id = _generateID();

    // Increment total questions in the new questions' quiz by one
    await quizCollection
        .where('id', isEqualTo: question.quizID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        Quiz quiz = quizFromSnapshot(doc);

        int totalQuestions = quiz.questionCount!;

        await quizCollection.doc(question.quizID).update({
          "questionCount": (totalQuestions + 1),
        });
      })
    });

    // Create the question document
    return await questionCollection.doc(id).set({
      'id': id,
      'quizID': question.quizID,
      'questionNumber': question.questionNumber,
      'questionText': question.questionText,
      'correctAnswer': question.correctAnswer,
      'questionType': 'NWQ'
    });
  }


  // Delete a question document from the Questions collection
  // Whilst also decrementing the total number of questions contained within
  // the new question's quiz
  // And decrementing all the question numbers of questions after the
  // deleted question in the quiz
  Future deleteQuestion(String id) async {
    // Fetch the question document to delete
    await questionCollection
        .where('id', isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        // Fetch the question document's question number and quiz id
        // So that all questions after the deleted question can have their
        // question number in the quiz moved down by one
        Question question = questionFromSnapshot(doc);

        int questionNumber = question.questionNumber!;
        String quizID = question.quizID!;

        // Fetch all questions after the deleted question in the quiz
        await questionCollection
            .where('quizID', isEqualTo: quizID)
            .where('questionNumber', isGreaterThan: questionNumber)
            .get()
            .then((QuerySnapshot querySnapshot) =>
        {
          querySnapshot.docs.forEach((doc) async {

            Question furtherQuestion = questionFromSnapshot(doc);

            // Decrement their question number by one
            String questionID = furtherQuestion.id!;
            int currentQuestionNumber = furtherQuestion.questionNumber!;
            await questionCollection.doc(questionID).update({
              "questionNumber": (currentQuestionNumber - 1),
            });
          })
        });


        // Decrement the total number of questions in the quiz by one
        await quizCollection
            .where('id', isEqualTo: quizID)
            .get()
            .then((QuerySnapshot querySnapshot) =>
        {
          querySnapshot.docs.forEach((doc) async {

            Quiz quiz = quizFromSnapshot(doc);

            int totalQuestions = quiz.questionCount!;

            await quizCollection.doc(quizID).update({
              "questionCount": (totalQuestions - 1),
            });
          })
        });


        // Finally, delete the question's document
        String questionID = doc["id"];
        // Delete the question
        await questionCollection
            .doc(questionID)
            .delete();
      })
    });
  }


  // Update a multiple choice question document in the Questions collection
  Future updateMultipleChoiceQuestion(MultipleChoiceQuestion question) async {

    return await questionCollection.doc(question.id).update({
      "answerA": question.answerA,
      "answerB": question.answerB,
      "answerC": question.answerC,
      "answerD": question.answerD,
      "correctAnswer": question.correctAnswer,
      "questionText": question.questionText,
      "questionType": 'MCQ'
    });

  }


  // Update a nearest wins question document in the Questions collection
  // And delete any MCQ fields in the Question document if there are any
  // (in case the question was switched from a MCQ to a NWQ)
  Future updateNearestWinsQuestion(NearestWinsQuestion question) async {

    return await questionCollection.doc(question.id).update({
      "correctAnswer": question.correctAnswer,
      "questionText": question.questionText,
      "questionType": 'NWQ',
      "answerA": FieldValue.delete(),
      "answerB": FieldValue.delete(),
      "answerC": FieldValue.delete(),
      "answerD": FieldValue.delete()
    });

  }


  // Return a Quiz Model object from a given Quiz snapshot
  Quiz quizFromSnapshot(var snapshotList) {
    return Quiz(
      id: snapshotList['id'],
      quizTitle: snapshotList['quizTitle'],
      quizEnded: snapshotList['quizEnded'],
      questionCount: snapshotList['questionCount'],
      isActive: snapshotList['isActive'],
      currentQuestion: snapshotList['currentQuestion'],
      creationDate: snapshotList['creationDate'],
    );
  }


  // Insert a new quiz document into the Quizzes collection
  Future createQuiz(String quizTitle) async {

    String id = _generateID();

    return await quizCollection.doc(id).set({
      'id': id,
      'currentQuestion' : 1,
      'isActive': false,
      'questionCount': 0,
      'quizEnded': false,
      'quizTitle': quizTitle,
      'creationDate': FieldValue.serverTimestamp(),
    });
  }


  // Delete a quiz document inside of the Quizzes collection
  // Whilst also deleting all of the question documents from the
  // Questions collection that are contained within the deleted quiz
  Future deleteQuiz(String id) async {

    // Delete all questions from quiz
    await questionCollection
        .where('quizID', isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {
        String questionID = doc["id"];
        await questionCollection
            .doc(questionID)
            .delete();
      })
    });

    // Delete the quiz document itself
    return quizCollection.doc(id).delete();
  }


  // Update a quiz document's quizTitle property inside of the
  // Quizzes collection
  Future updateQuiz(String id, String quizTitle) async {
    return await quizCollection.doc(id).update({"quizTitle": quizTitle});
  }


  // Mark the inputted quiz as active and set the non active quiz marker in the
  // database to false
  Future startQuiz(String quizID) async {
    // Mark the Quiz document that is used to mark that there
    // isn't a quiz currently active as inactive
    quizCollection.doc('cy7RWIJ3VGIXlHSM1Il8').update({"isActive": false});

    // Mark the inputted quiz document as active
    return quizCollection
        .doc(quizID)
        .update({"isActive": true, "quizEnded": false});
  }


  // Retrieve how many questions are in a given quiz
  Future retrieveQuestionCount(String quizID) async {

    int questionCount = -1;

    // Retrieve the question count from the quiz document with the matching id
    await quizCollection
        .where('id', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {

        Quiz quiz = quizFromSnapshot(doc);

        questionCount = quiz.questionCount!;
        })
      });

    return questionCount;
  }


  // Mark the inputted quiz as inactive and set the non active quiz marker in
  // the database to true
  // Also reset all the currentQuestionCorrect booleans in the
  // Scores collection for the active quiz to false
  // And reset the currentQuestionAnswer variables to be empty
  // Also for each winning user of the quiz add one win to their User document
  // in the Users collection
  // And add the win DateTime to the User document
  // And update the user's leaderboard documents
  Future endQuiz(String quizID, int highestScore) async {
    // Mark the Quiz document that is used to mark that there
    // isn't a quiz currently active as active
    quizCollection.doc('cy7RWIJ3VGIXlHSM1Il8').update({"isActive": true});

    // Mark the inputted quiz document as inactive
    await quizCollection
        .doc(quizID)
        .update({"isActive": false, "quizEnded": true, "currentQuestion": 1});

    // A user only wins a quiz if they get at least one question correct
    if (highestScore != 0) {
      // Retrieve the Score documents related to the winning users of the given
      // quiz
      await scoreCollection
          .where('quizID', isEqualTo: quizID)
          .where('score', isEqualTo: highestScore)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        // For each winning user add one win to their User document in the
        // Users collection
        querySnapshot.docs.forEach((doc) async {

          Score score = scoreFromSnapshot(doc);

          String userID = score.userID!;

          // Add one win to the User document
          // And add the win DateTime to the User document
          // And update the user's leaderboard documents
          await addWin(userID, highestScore);
        })
      });
    }

    // Reset all the currentQuestionCorrect booleans for the active quiz to
    // false
    // To allow this quiz to be restarted without accidentally giving out
    // any points
    // Also reset the currentQuestionAnswer variables to be empty
    return scoreCollection
        .where('quizID', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) async {

        Score score = scoreFromSnapshot(doc);

        String scoreID = score.id!;

        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': false,'currentQuestionAnswer': ''});
      })
    });
  }


  // Return a Score Model object from a given Score snapshot
  Score scoreFromSnapshot(var snapshotList) {
    return Score(
      id: snapshotList['id'],
      currentQuestionCorrect: snapshotList['currentQuestionCorrect'],
      quizID: snapshotList['quizID'],
      userID: snapshotList['userID'],
      score: snapshotList['score'],
      currentQuestionAnswer: snapshotList['currentQuestionAnswer']
    );
  }


  // Move an inputted quiz to its next question and mark whether the quiz
  // has ended or not

  // Also if the current question is a nearest wins question, determine which
  // user submitted answer is the closest to (or matches) the correct answer
  // Then set any Score documents containing this answer to have the current
  // question correct

  // Also add 10 points to each score document with the currentQuestionCorrect
  // boolean set to true (if it is a multiple choice question)
  // Add 30 points if its a nearest wins question
  // And then set each one of these booleans to false so they are prepared
  // for the next question.

  // This function also resets each score to zero if it is the start of the
  // quiz in case this quiz has been played before by the users taking part
  Future nextQuestion(
      String quizID,
      int currentQuestionNumber,
      int questionCount) async {

    currentQuestionNumber++;

    // If the previous question is the first question in the quiz
    // Reset all score values to 0 in case this quiz has been played before
    // by the users taking part
    if (currentQuestionNumber == 2) {
      await scoreCollection
          .where('quizID', isEqualTo: quizID)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        querySnapshot.docs.forEach((doc) async {

          Score score = scoreFromSnapshot(doc);

          String scoreID = score.id!;

          await scoreCollection
              .doc(scoreID)
              .update({'score': 0});
        })
      });
    }

    // If the previous question was the last question in the quiz
    if (currentQuestionNumber > questionCount) {
      // Also mark the quiz as ended in the database
      await quizCollection.doc(quizID).update(
          {"currentQuestion": currentQuestionNumber, "quizEnded": true});
    }
    // Otherwise
    else {
      // Just increment the current question number variable on the
      // inputted Quiz Document
      await quizCollection
          .doc(quizID)
          .update({"currentQuestion": currentQuestionNumber});
    }



    // Determine the type of the previous question
    String questionType = "";

    await questionCollection
        .where('quizID', isEqualTo: quizID)
        .where('questionNumber', isEqualTo: currentQuestionNumber - 1)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        questionType = doc["questionType"];
      })
    });


    // If it is a nearest wins question type
    if (questionType == "NWQ") {

      // Retrieve the correct answer of the currently active question in the
      // retrieved quiz
      // Using the retrieved quiz id and current question number
      double correctAnswer = 255564;

      await questionCollection
          .where('quizID', isEqualTo: quizID)
          .where('questionNumber', isEqualTo: currentQuestionNumber - 1)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        querySnapshot.docs.forEach((doc) {
          correctAnswer = doc["correctAnswer"];
        })
      });


      // For each score document in the Scores collection for the currently
      // active quiz
      // Retrieve the closest or matching user submitted answer for the nearest
      // wins question
      double closestAnswer = 0;
      double difference = double.maxFinite;
      await scoreCollection
          .where('quizID', isEqualTo: quizID)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        querySnapshot.docs.forEach((doc) async {

          Score score = scoreFromSnapshot(doc);

          // If this user has submitted an answer
          if (score.currentQuestionAnswer != '') {

            // Determine the absolute difference between the correct answer and
            // this user's submitted answer
            // If it is the smallest absolute difference so far, then mark the
            // user's submitted answer as the closest one found so far
            if (correctAnswer > double.parse(score.currentQuestionAnswer)) {
              if ((correctAnswer - double.parse(score.currentQuestionAnswer)) < difference) {
                difference = (correctAnswer - double.parse(score.currentQuestionAnswer));
                closestAnswer = double.parse(score.currentQuestionAnswer);
              }
            }
            // This else statement covers any exactly correct answers submitted too
            else {
              if ((double.parse(score.currentQuestionAnswer) - correctAnswer) < difference) {
                difference = (double.parse(score.currentQuestionAnswer) - correctAnswer);
                closestAnswer = double.parse(score.currentQuestionAnswer);
              }
            }
          }
        })
      });


      // Set currentQuestionCorrect booleans in Score documents to true if their
      // answer matches the closest answer found
      await scoreCollection
          .where('quizID', isEqualTo: quizID)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        querySnapshot.docs.forEach((doc) async {

          // Retrieve the ID of the Score document
          Score score = scoreFromSnapshot(doc);
          String scoreID = score.id!;

          if (double.parse(score.currentQuestionAnswer!) == closestAnswer) {
            await scoreCollection
                .doc(scoreID)
                .update({'currentQuestionCorrect': true});
          }
        })
      });


      // For each score document in the Scores collection for the currently
      // active quiz
      await scoreCollection
          .where('quizID', isEqualTo: quizID)
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) async {

          // Retrieve the document's id, whether the user tied to the document
          // has the previous question correct, and their overall score for the
          // currently active quiz

          Score score = scoreFromSnapshot(doc);

          String scoreID = score.id!;
          bool answerCorrect = score.currentQuestionCorrect!;
          int currentScore = score.score!;

          // If the user tied to this Score document got the previous question
          // correct
          if (answerCorrect) {
            // Add 30 points to their current score
            await scoreCollection
                .doc(scoreID)
                .update({'score': currentScore + 30});

            // And reset the boolean that marks whether they have the current
            // question correct to false
            // And reset the currentQuestionAnswer field
            await scoreCollection
                .doc(scoreID)
                .update({'currentQuestionCorrect': false, 'currentQuestionAnswer': ''});
          }

          // For any incorrect answers, reset currentQuestionCorrect boolean and
          // reset currentQuestionAnswer field
          else {
            await scoreCollection
                .doc(scoreID)
                .update({'currentQuestionCorrect': false, 'currentQuestionAnswer': ''});
          }
        })
      });
    }


    // If it is a Multiple Choice Question
    else if (questionType == "MCQ") {

      // For each score document in the Scores collection for the currently
      // active quiz
      await scoreCollection
          .where('quizID', isEqualTo: quizID)
          .get()
          .then((QuerySnapshot querySnapshot) => {
        querySnapshot.docs.forEach((doc) async {

          // Retrieve the document's id, whether the user tied to the document
          // has the previous question correct, and their overall score for the
          // currently active quiz

          Score score = scoreFromSnapshot(doc);

          String scoreID = score.id!;
          bool answerCorrect = score.currentQuestionCorrect!;
          int currentScore = score.score!;

          // If the user tied to this Score document got the previous question
          // correct
          if (answerCorrect) {
            // Add 10 points to their current score
            await scoreCollection
                .doc(scoreID)
                .update({'score': currentScore + 10});
            // And reset the boolean that marks whether they have the current
            // question correct to false
            await scoreCollection
                .doc(scoreID)
                .update({'currentQuestionCorrect': false});
          }

          // Reset each user's currentQuestionAnswer field so no buttons are
          // remained selected on the next question
          await scoreCollection
              .doc(scoreID)
              .update({'currentQuestionAnswer': ''});
        })
      });
    }
  }


  // Score document is created or updated to store whether the
  // currently logged-in user has the correct answer currently selected on the
  // current question in the currently active quiz.
  Future submitMultipleChoiceAnswer(String answer) async {

    // Retrieve the currently active quiz id and current question number
    String quizID = "Not Set";
    int currentQuestionNumber = 300;

    await quizCollection
        .where('isActive', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                quizID = doc['id'];
                currentQuestionNumber = doc['currentQuestion'];
              })
            });

    // Retrieve the correct answer of the currently active question in the
    // retrieved quiz
    // Using the retrieved quiz id and current question number
    String correctAnswer = "Not Set";

    await questionCollection
        .where('quizID', isEqualTo: quizID)
        .where('questionNumber', isEqualTo: currentQuestionNumber)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                correctAnswer = doc["correctAnswer"];
              })
            });

    // Compare the user's answer to the retrieved correct answer
    // And store whether it is correct
    bool answerCorrect = false;
    if (answer == correctAnswer) {
      answerCorrect = true;
    }

    // Retrieve the currently logged-in user's ID from the
    // authentication service
    String userID = _auth.currentUID()!;


    // Attempt to retrieve the logged-in user's Score document for the
    // currently active quiz
    String scoreID = "Not Set";

    await scoreCollection
        .where('userID', isEqualTo: userID)
        .where('quizID', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                scoreID = doc["id"];
              })
            });

    // Determine whether or not this Score document already exists
    // If updating an existing Score document
    if (scoreID != "Not Set") {
      // Update the Score document's currentQuestionCorrect boolean to store
      // whether the user has the correct answer currently selected
      if (answerCorrect) {
        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': true, 'currentQuestionAnswer': answer});
      } else {
        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': false, 'currentQuestionAnswer': answer});
      }
    }
    // Otherwise, if creating a new Score document
    else {
      // Create a score doc with an auto generated id of 20 characters
      scoreID = _generateID();

      Score newScore = Score(
        id: scoreID,
        currentQuestionCorrect: false,
        quizID: quizID,
        userID: userID,
        score: 0,
        currentQuestionAnswer: answer
      );

      // Create the Score document with the currentQuestionCorrect boolean
      // storing whether the user has the correct answer currently selected
      if (answerCorrect) {
        newScore.currentQuestionCorrect = true;
      }

      await scoreCollection.doc(scoreID).set({
        'id': newScore.id,
        'quizID': newScore.quizID,
        'userID': newScore.userID,
        'score': newScore.score,
        'currentQuestionCorrect': newScore.currentQuestionCorrect,
        'currentQuestionAnswer': newScore.currentQuestionAnswer
      });
    }
  }


  // Score document is created or updated to store the users currently submitted
  // answer
  // And if the user guesses exactly correctly then the score document is also
  // updated to store that they have the current question correct
  Future submitNearestWinsAnswer(var answer) async {

    // Retrieve the currently active quiz id and current question number
    String quizID = "Not Set";
    int currentQuestionNumber = 300;

    await quizCollection
        .where('isActive', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        quizID = doc['id'];
        currentQuestionNumber = doc['currentQuestion'];
      })
    });

    // Retrieve the correct answer of the currently active question in the
    // retrieved quiz
    // Using the retrieved quiz id and current question number
    double correctAnswer = -94345784;

    await questionCollection
        .where('quizID', isEqualTo: quizID)
        .where('questionNumber', isEqualTo: currentQuestionNumber)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        correctAnswer = doc["correctAnswer"];
      })
    });

    // Compare the user's answer to the retrieved correct answer
    // And store whether it is correct
    bool answerCorrect = false;
    if (double.parse(answer) == correctAnswer) {
      answerCorrect = true;
    }

    // Retrieve the currently logged-in user's ID from the
    // authentication service
    String userID = _auth.currentUID()!;


    // Attempt to retrieve the logged-in user's Score document for the
    // currently active quiz
    String scoreID = "Not Set";

    await scoreCollection
        .where('userID', isEqualTo: userID)
        .where('quizID', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        scoreID = doc["id"];
      })
    });

    // Determine whether or not this Score document already exists
    // If updating an existing Score document
    if (scoreID != "Not Set") {
      // Update the Score document's currentQuestionCorrect boolean to store
      // whether the user has the correct answer currently selected
      // And store the user's submitted answer
      if (answerCorrect) {
        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': true, 'currentQuestionAnswer': answer});
      } else {
        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': false, 'currentQuestionAnswer': answer});
      }
    }
    // Otherwise, if creating a new Score document
    else {
      // Create a score doc with an auto generated id of 20 characters
      scoreID = _generateID();

      Score newScore = Score(
          id: scoreID,
          currentQuestionCorrect: false,
          quizID: quizID,
          userID: userID,
          score: 0,
          currentQuestionAnswer: answer
      );

      // Create the Score document with the currentQuestionCorrect boolean
      // storing whether the user has the correct answer currently submitted
      // And store the user's submitted answer
      if (answerCorrect) {
        newScore.currentQuestionCorrect = true;
      }

      await scoreCollection.doc(scoreID).set({
        'id': newScore.id,
        'quizID': newScore.quizID,
        'userID': newScore.userID,
        'score': newScore.score,
        'currentQuestionCorrect': newScore.currentQuestionCorrect,
        'currentQuestionAnswer': newScore.currentQuestionAnswer
      });
    }
  }


  // Retrieve the logged-in user's possibly submitted answer for the
  // current question in the active quiz
  // If no answer was submitted then "No Answer Submitted" is returned.
  Future retrieveSubmittedAnswer() async {

    // Retrieve the currently active quiz id and current question number
    String quizID = "Not Set";

    await quizCollection
        .where('isActive', isEqualTo: true)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        quizID = doc['id'];
      })
    });


    // Retrieve the currently logged-in user's ID from the
    // authentication service
    String userID = _auth.currentUID()!;


    // Attempt to retrieve the logged-in user's Score document for the
    // currently active quiz
    String currentQuestionAnswer = "";

    await scoreCollection
        .where('userID', isEqualTo: userID)
        .where('quizID', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        currentQuestionAnswer = doc["currentQuestionAnswer"];
      })
    });

    // Determine whether or not this user has submitted an answer for the
    // current question
    // (If no score document exists for this user and quiz then
    // currentQuestionAnswer will also be left empty)
    if (currentQuestionAnswer != "") {
      // Return the user's submitted answer
      return currentQuestionAnswer;
    }
    // Otherwise, if the user has not submitted any answers for the active quiz
    // They couldn't have previously submitted an answer for the current question
    else {
      // Return that the user has not submitted an answer
      return "No Answer Submitted";
    }
  }


  // Return a LeaderboardEntry Model object from a given Leaderboard Entry
  // snapshot
  LeaderboardEntry leaderboardEntryFromSnapshot(var snapshotList) {
    return LeaderboardEntry(
        id: snapshotList['id'],
        seasonNumber: snapshotList['seasonNumber'],
        userID: snapshotList['userID'],
        totalWins: snapshotList['totalWins'],
        totalPoints: snapshotList['totalPoints']
    );
  }


  // Return a MonthlyLeaderboardDoc Model object from a given Monthly
  // Leaderboard Entry snapshot
  MonthlyLeaderboardDoc monthlyLeaderboardDocFromSnapshot(var snapshotList) {
    return MonthlyLeaderboardDoc(
        id: snapshotList['id'],
        currentSeason: snapshotList['currentSeason'],
        currentMonth: snapshotList['currentMonth'],
        prizes: snapshotList['prizes']
    );
  }


  // Return a SemesterlyLeaderboardDoc Model object from a given Semesterly
  // Leaderboard Entry snapshot
  SemesterlyLeaderboardDoc semesterlyLeaderboardDocFromSnapshot(
      var snapshotList
      ) {

    return SemesterlyLeaderboardDoc(
        id: snapshotList['id'],
        currentSeason: snapshotList['currentSeason'],
        prizes: snapshotList['prizes']
    );
  }


  // Return a YearlyLeaderboardDoc Model object from a given Yearly Leaderboard
  // Entry snapshot
  YearlyLeaderboardDoc yearlyLeaderboardDocFromSnapshot(var snapshotList) {
    return YearlyLeaderboardDoc(
        id: snapshotList['id'],
        currentSeason: snapshotList['currentSeason'],
        prizes: snapshotList['prizes']
    );
  }


  // Returns the current season of the monthly leaderboard
  Future<int> retrieveCurrentMonthlySeason() async {

    int currentSeason = -1;

    // Retrieve the monthly leaderboard singleton document
    await monthlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'AoJjjYhtjLeYQhc2s8zK')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Retrieve the current season
        MonthlyLeaderboardDoc retrievedMonthlyDoc = monthlyLeaderboardDocFromSnapshot(doc);
        currentSeason = retrievedMonthlyDoc.currentSeason!;
      })
    });

    return currentSeason;
  }


  // Returns the current season of the semesterly leaderboard
  Future<int> retrieveCurrentSemesterlySeason() async {

    int currentSeason = -1;

    // Retrieve the semesterly leaderboard singleton document
    await semesterlyLeaderboardEntriesCollection
        .where('id', isEqualTo: '2RpLeBNHCgOcHzjORDCQ')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Retrieve the current season
        SemesterlyLeaderboardDoc retrievedSemesterlyDoc
                                    = semesterlyLeaderboardDocFromSnapshot(doc);
        currentSeason = retrievedSemesterlyDoc.currentSeason!;
      })
    });

    return currentSeason;
  }


  // Returns the current season of the yearly leaderboard
  Future<int> retrieveCurrentYearlySeason() async {

    int currentSeason = -1;

    // Retrieve the yearly leaderboard singleton document
    await yearlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'OrAMZAbg8wi3UTUgcYth')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Retrieve the current season
        YearlyLeaderboardDoc retrievedYearlyDoc
                                        = yearlyLeaderboardDocFromSnapshot(doc);
        currentSeason = retrievedYearlyDoc.currentSeason!;
      })
    });

    return currentSeason;
  }


  // Update the current month stored in the monthly leaderboard doc
  // And increase the current season number stored in it
  // And add an extra element to the prizes array
  // And add a monthly win and the monthly win DateTime to any winners
  Future endMonthSeason(int currentMonth) async {

    int retrievedCurrentSeason = -1;

    // Retrieve the current season number
    await monthlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'AoJjjYhtjLeYQhc2s8zK')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        MonthlyLeaderboardDoc retrievedMonthlyDoc = monthlyLeaderboardDocFromSnapshot(doc);

        retrievedCurrentSeason = retrievedMonthlyDoc.currentSeason!;

        var oldArray = retrievedMonthlyDoc.prizes;
        int oldLength = oldArray!.length;

        // Declare a new array with one more element than the old array
        var updatedArray = List.filled(
            oldLength + 1, "Prize Not Set", growable: false
        );

        // Fill the larger array with the old array's data (other than the new
        // final element which already has "Prize Not Set" stored in it)
        for (int oldArrayIndex = 0; oldArrayIndex < oldLength; oldArrayIndex++) {
          updatedArray[oldArrayIndex] = oldArray[oldArrayIndex];
        }

        // Update the document with the new current month and season number
        // And extra element in the prizes array
        return await monthlyLeaderboardEntriesCollection.doc('AoJjjYhtjLeYQhc2s8zK')
            .update({
          "currentMonth": currentMonth,
          "currentSeason": (retrievedCurrentSeason + 1),
          "prizes": updatedArray
        });
      })
    });



    // Determine the highest total wins of the season

    int highestTotalWins = -1;
    await monthlyLeaderboardEntriesCollection
        .where('seasonNumber', isEqualTo: retrievedCurrentSeason)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Determine the highest total wins of the season
        LeaderboardEntry monthlyEntry = leaderboardEntryFromSnapshot(doc);

        if (monthlyEntry.totalWins! > highestTotalWins) {
          highestTotalWins = monthlyEntry.totalWins!;
        }

      })
    });


    // If there is a highest total wins
    if (highestTotalWins != -1) {

      // Retrieve the leaderboard entry for each winner of the season

      await monthlyLeaderboardEntriesCollection
          .where('totalWins', isEqualTo: highestTotalWins)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        // For the found document,
        querySnapshot.docs.forEach((doc) async {

          // Add one monthly win and the monthly win date to the related
          // document in the Users collection

          LeaderboardEntry winningEntry = leaderboardEntryFromSnapshot(doc);

          // Retrieve the user's current monthly wins
          int monthlyWins = -1;
          CurrentUser retrievedUser = await getUserData(winningEntry.userID);
          monthlyWins = retrievedUser.monthlyWins;

          // Update the User document to contain the extra monthly win and
          // monthly win date
          await userCollection.doc(winningEntry.userID).update({
            'monthlyWins': (monthlyWins + 1),
            'monthlyWinDates': FieldValue.arrayUnion([DateTime.now()]),
          });

        })
      });
    }
  }


  // Update the prize of a given monthly season
  Future updateMonthlyPrize(String prize, int seasonNumber) async {

    var updatedArray;

    // Retrieve the prizes array of the current season
    await monthlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'AoJjjYhtjLeYQhc2s8zK')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        MonthlyLeaderboardDoc monthlyDoc = monthlyLeaderboardDocFromSnapshot(doc);

        // Create a local copy of the array and update the prize
        updatedArray = monthlyDoc.prizes;
        updatedArray[seasonNumber - 1] = prize;

        // Overwrite the array in the database with the updated local copy
        monthlyLeaderboardEntriesCollection.doc('AoJjjYhtjLeYQhc2s8zK')
            .update({"prizes": updatedArray});
      })
    });
  }


  // Increase the current season number stored in semesterly leaderboard doc
  // And add an extra element to the prizes array
  // And add a semesterly win and the semesterly win DateTime to any winners
  Future endSemesterSeason() async {

    int retrievedCurrentSeason = -1;

    // Retrieve the current season number
    await semesterlyLeaderboardEntriesCollection
        .where('id', isEqualTo: '2RpLeBNHCgOcHzjORDCQ')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        SemesterlyLeaderboardDoc retrievedSemesterlyDoc = semesterlyLeaderboardDocFromSnapshot(doc);

        retrievedCurrentSeason = retrievedSemesterlyDoc.currentSeason!;

        var oldArray = retrievedSemesterlyDoc.prizes;
        int oldLength = oldArray!.length;

        // Declare a new array with one more element than the old array
        var updatedArray = List.filled(
            oldLength + 1, "Prize Not Set", growable: false
        );

        // Fill the larger array with the old array's data (other than the new
        // final element which already has "Prize Not Set" stored in it)
        for (int oldArrayIndex = 0; oldArrayIndex < oldLength; oldArrayIndex++) {
          updatedArray[oldArrayIndex] = oldArray[oldArrayIndex];
        }

        // Update the document with the new season number
        // And add a new element to the prizes array
        return await semesterlyLeaderboardEntriesCollection.doc('2RpLeBNHCgOcHzjORDCQ')
            .update({
          "currentSeason": (retrievedCurrentSeason + 1),
          "prizes": updatedArray
        });
      })
    });



    // Determine the highest total wins of the season

    int highestTotalWins = -1;
    await semesterlyLeaderboardEntriesCollection
        .where('seasonNumber', isEqualTo: retrievedCurrentSeason)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Determine the highest total wins of the season
        LeaderboardEntry semesterlyEntry = leaderboardEntryFromSnapshot(doc);

        if (semesterlyEntry.totalWins! > highestTotalWins) {
          highestTotalWins = semesterlyEntry.totalWins!;
        }

      })
    });


    // If there is a highest total wins
    if (highestTotalWins != -1) {

      // Retrieve the leaderboard entry for each winner of the season

      await semesterlyLeaderboardEntriesCollection
          .where('totalWins', isEqualTo: highestTotalWins)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        // For the found document,
        querySnapshot.docs.forEach((doc) async {

          // Add one semesterly win and the semesterly win date to the related
          // document in the Users collection

          LeaderboardEntry winningEntry = leaderboardEntryFromSnapshot(doc);

          // Retrieve the user's current semesterly wins
          int semesterlyWins = -1;
          CurrentUser retrievedUser = await getUserData(winningEntry.userID);
          semesterlyWins = retrievedUser.semesterlyWins;

          // Update the User document to contain the extra semesterly win and
          // semesterly win date
          await userCollection.doc(winningEntry.userID).update({
            'semesterlyWins': (semesterlyWins + 1),
            'semesterlyWinDates': FieldValue.arrayUnion([DateTime.now()])
          });

        })
      });
    }
  }


  // Update the prize of a given semesterly season
  Future updateSemesterlyPrize(String prize, int seasonNumber) async {

    var updatedArray;

    // Retrieve the prizes array of the current season
    await semesterlyLeaderboardEntriesCollection
        .where('id', isEqualTo: '2RpLeBNHCgOcHzjORDCQ')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        SemesterlyLeaderboardDoc semesterlyDoc = semesterlyLeaderboardDocFromSnapshot(doc);

        // Create a local copy of the array and update the prize
        updatedArray = semesterlyDoc.prizes;
        updatedArray[seasonNumber - 1] = prize;

        // Overwrite the array in the database with the updated local copy
        semesterlyLeaderboardEntriesCollection.doc('2RpLeBNHCgOcHzjORDCQ')
            .update({"prizes": updatedArray});
      })
    });
  }


  // Increase the current season number stored in yearly leaderboard doc
  // And add an extra element to the prizes array
  // And add a yearly win and the yearly win DateTime to any winners
  Future endYearSeason() async {

    int retrievedCurrentSeason = -1;

    // Retrieve the current season number
    await yearlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'OrAMZAbg8wi3UTUgcYth')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        YearlyLeaderboardDoc retrievedYearlyDoc = yearlyLeaderboardDocFromSnapshot(doc);

        retrievedCurrentSeason = retrievedYearlyDoc.currentSeason!;

        var oldArray = retrievedYearlyDoc.prizes;
        int oldLength = oldArray!.length;

        // Declare a new array with one more element than the old array
        var updatedArray = List.filled(
            oldLength + 1, "Prize Not Set", growable: false
        );

        // Fill the larger array with the old array's data (other than the new
        // final element which already has "Prize Not Set" stored in it)
        for (int oldArrayIndex = 0; oldArrayIndex < oldLength; oldArrayIndex++) {
          updatedArray[oldArrayIndex] = oldArray[oldArrayIndex];
        }

        // Update the document with the new season number
        // And add an extra element to the prizes array
        return await yearlyLeaderboardEntriesCollection.doc('OrAMZAbg8wi3UTUgcYth')
            .update({
          "currentSeason": (retrievedCurrentSeason + 1),
          "prizes": updatedArray
        });
      })
    });



    // Determine the highest total wins of the season

    int highestTotalWins = -1;
    await yearlyLeaderboardEntriesCollection
        .where('seasonNumber', isEqualTo: retrievedCurrentSeason)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Determine the highest total wins of the season
        LeaderboardEntry yearlyEntry = leaderboardEntryFromSnapshot(doc);

        if (yearlyEntry.totalWins! > highestTotalWins) {
          highestTotalWins = yearlyEntry.totalWins!;
        }

      })
    });


    // If there is a highest total wins
    if (highestTotalWins != -1) {

      // Retrieve the leaderboard entry for each winner of the season

      await yearlyLeaderboardEntriesCollection
          .where('totalWins', isEqualTo: highestTotalWins)
          .get()
          .then((QuerySnapshot querySnapshot) =>
      {
        // For the found document,
        querySnapshot.docs.forEach((doc) async {

          // Add one yearly win and the yearly win date to the related
          // document in the Users collection

          LeaderboardEntry winningEntry = leaderboardEntryFromSnapshot(doc);

          // Retrieve the user's current yearly wins
          int yearlyWins = -1;
          CurrentUser retrievedUser = await getUserData(winningEntry.userID);
          yearlyWins = retrievedUser.yearlyWins;

          // Update the User document to contain the extra yearly win and
          // yearly win date
          await userCollection.doc(winningEntry.userID).update({
            'yearlyWins': (yearlyWins + 1),
            'yearlyWinDates': FieldValue.arrayUnion([DateTime.now()])
          });

        })
      });
    }
  }


  // Update the prize of a given yearly season
  Future updateYearlyPrize(String prize, int seasonNumber) async {

    var updatedArray;

    // Retrieve the prizes array of the current season
    await yearlyLeaderboardEntriesCollection
        .where('id', isEqualTo: 'OrAMZAbg8wi3UTUgcYth')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        YearlyLeaderboardDoc yearlyDoc = yearlyLeaderboardDocFromSnapshot(doc);

        // Create a local copy of the array and update the prize
        updatedArray = yearlyDoc.prizes;
        updatedArray[seasonNumber - 1] = prize;

        // Overwrite the array in the database with the updated local copy
        yearlyLeaderboardEntriesCollection.doc('OrAMZAbg8wi3UTUgcYth')
            .update({"prizes": updatedArray});
      })
    });
  }


  // Return a MenuGroup Model object from a given MenuGroup snapshot
  MenuGroup menuGroupFromSnapshot(var snapshotList) {
    return MenuGroup(id: snapshotList['id'], name: snapshotList['name']);
  }


  // Insert a new Menu Group document into the MenuGroup collection
  Future createMenuGroup(MenuGroup newMenuGroup) async {
    String id = _generateID();

    // Create the MenuGroup document
    return await menuGroupCollection.doc(id).set({
      'id': id,
      'name': newMenuGroup.name,
    });
  }


  // Update a Menu Group's document's name property inside of the
  // MenuGroup collection
  Future updateMenuGroup(MenuGroup menuGroup) async {
    return await menuGroupCollection.doc(menuGroup.id)
        .update({"name": menuGroup.name});
  }


  // Delete a Menu Group document along with all the MenuSubGroup documents
  // related to it
  Future deleteMenuGroup(String id) async {

    // Delete all related MenuSubGroup documents
    await menuSubGroupCollection
        .where('MenuGroupID', isEqualTo: id)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {
        String subGroupID = doc["id"];
        await menuSubGroupCollection
            .doc(subGroupID)
            .delete();
      })
    });

    // Delete the MenuGroup document itself
    return menuGroupCollection.doc(id).delete();
  }


  // Return a MenuSubGroup Model object from a given MenuSubGroup snapshot
  MenuSubGroup menuSubGroupFromSnapshot(var snapshotList) {
    return MenuSubGroup(
        id: snapshotList['id'],
        name: snapshotList['name'],
        menuGroupID: snapshotList['MenuGroupID'],
        menuItems: snapshotList['MenuItems'],
    );
  }


  // Insert a new Menu Sub Group document into the MenuSubGroup collection
  Future createMenuSubGroup(MenuSubGroup newMenuSubGroup) async {
    String id = _generateID();

    // Create the MenuSubGroup document
    return await menuSubGroupCollection.doc(id).set({
      'MenuGroupID': newMenuSubGroup.menuGroupID,
      'name': newMenuSubGroup.name,
      'id': id,
      'MenuItems': <String>[],
    });
  }


  // Update a Menu Sub Group's document's name property inside of the
  // MenuSubGroup collection
  Future updateMenuSubGroup(MenuSubGroup menuSubGroup) async {
    return await menuSubGroupCollection.doc(menuSubGroup.id)
        .update({"name": menuSubGroup.name});
  }


  // Delete a MenuSubGroup document including it's MenuItems array
  Future deleteMenuSubGroup(String id) async {
    return menuSubGroupCollection.doc(id).delete();
  }


  // Add a new Menu Item to the given Menu Sub Group's MenuItems array inside
  // of the MenuSubGroup document
  // Duplicate Menu Items will not be added to the same Menu Sub Group
  Future createMenuItem(String subGroupID, String itemDetails) async {

    // Retrieve the MenuSubGroup document
    await menuSubGroupCollection
        .where('id', isEqualTo: subGroupID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Create a list containing one-element that describes the new item to
        // be added
        var newItem = [itemDetails];

        // Add this new item to the array by conducting a union between the
        // two lists
        // This implicitly stops duplicate items from being added to sub groups
        // And if the array doesn't already exist, it will be created
        menuSubGroupCollection.doc(subGroupID).update({"MenuItems": FieldValue.arrayUnion(newItem)});
      })
    });
  }


  // Update a MenuItems array element, this array is stored in the given Menu Sub Group document
  Future updateMenuItem(String subGroupID, String oldItemDetails, String newItemDetails) async {

    // Retrieve the MenuSubGroup document
    await menuSubGroupCollection
        .where('id', isEqualTo: subGroupID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Retrieve the existing array from the document
        var updatedArray = doc['MenuItems'];

        // Update the array
        // Do not need to worry about duplicates being renamed here as duplicates
        // cannot be created within Sub Groups in the first place
        for (var itemIndex = 0 ; itemIndex < updatedArray.length; itemIndex++) {
          if (updatedArray[itemIndex] == oldItemDetails) {
            updatedArray[itemIndex] = newItemDetails;
          }
        }

        // Write the updated array to the document
        menuSubGroupCollection.doc(subGroupID).update({"MenuItems": updatedArray});
      })
    });
  }


  // Delete a MenuItems array element, this array is stored in the given Menu Sub Group document
  Future deleteMenuItem(String subGroupID, String itemDetails) async {

    // Retrieve the MenuSubGroup document
    await menuSubGroupCollection
        .where('id', isEqualTo: subGroupID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        // Create a list containing one-element that describes the item to be
        // deleted
        var deletedItem = [itemDetails];

        // Delete this item from the array
        // Do not need to worry about duplicates being deleted here as duplicates
        // cannot be created within Sub Groups in the first place
        menuSubGroupCollection.doc(subGroupID).update(
            {"MenuItems": FieldValue.arrayRemove(deletedItem)}
            );
      })
    });
  }


  // Return a BandaokeQueue Model object from a given BandaokeQueue snapshot
  BandaokeQueue bandaokeQueueFromSnapshot(var snapshotList) {
    return BandaokeQueue(
      id: snapshotList['id'],
      queuedMembers: snapshotList['queuedMembers'],
    );
  }


  // Add a new entry to the bandaoke queue
  Future queue(String uid, String songTitle) async {
    // Add the queue entry details to a map
    var newEntryMap = {'uid':uid, 'songTitle':songTitle};

    // Create a one-element array containing the map
    // (Since the queuedMembers property in the document is an array of maps)
    var newEntryArray = [newEntryMap];

    // Add this new item to the array in the document by conducting a union
    // between the two arrays
    bandaokeQueueCollection.doc('Z4NtbE7IQ2vp32WHkpYY').update(
        {"queuedMembers": FieldValue.arrayUnion(newEntryArray)}
        );
  }


  // Remove a specific entry from the bandaoke queue
  Future dequeue(String uid, String songTitle) async {
    // Add the queue entry details to a map
    var entryMap = {'uid':uid, 'songTitle':songTitle};

    // Create a one-element array containing the map
    // (Since the queuedMembers property in the document is an array of maps)
    var entryArray = [entryMap];

    // Delete this map from the array
    bandaokeQueueCollection.doc('Z4NtbE7IQ2vp32WHkpYY').update(
        {"queuedMembers": FieldValue.arrayRemove(entryArray)}
        );
  }


  // Advance the bandaoke queue
  Future nextSinger() async {
    // Retrieve the array to obtain the details in the first element
    // so it can be deleted
    // Retrieve the BandaokeQueue document
    await bandaokeQueueCollection
        .where('id', isEqualTo: 'Z4NtbE7IQ2vp32WHkpYY')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        BandaokeQueue bandaokeQueue = bandaokeQueueFromSnapshot(doc);

        // If there are any queued members
        if (bandaokeQueue.queuedMembers!.isNotEmpty) {
          // Create a one-element array containing the map that describes the
          // item to be deleted
          var deletedItem = [bandaokeQueue.queuedMembers![0]];

          // Delete this item from the array
          bandaokeQueueCollection.doc('Z4NtbE7IQ2vp32WHkpYY').update(
              {"queuedMembers": FieldValue.arrayRemove(deletedItem)}
          );
        }
      })
    });
  }


  // Clear the bandaoke queue
  Future clearQueue() async {
    // Set the queuedMembers array to be an empty array
    bandaokeQueueCollection.doc('Z4NtbE7IQ2vp32WHkpYY').update(
        {"queuedMembers": []}
        );
  }


  // Retrieve the position of a user in the bandaoke queue
  Future retrievePosition(String uid) async {
    int position = 0;

    // Retrieve the bandaoke queue document
    await bandaokeQueueCollection
        .where('id', isEqualTo: 'Z4NtbE7IQ2vp32WHkpYY')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        BandaokeQueue bandaokeQueue = bandaokeQueueFromSnapshot(doc);

        // If there are any queued members
        if (bandaokeQueue.queuedMembers!.isNotEmpty) {

          for (int index = 0; index < bandaokeQueue.queuedMembers!.length; index++) {
            // Find the user's map in the array
            if (bandaokeQueue.queuedMembers![index]['uid'] == uid) {
              // The position in the queue is the map's index plus 1
              position = index + 1;
            }
          }

        }
      })
    });

    return position;
  }


  // Retrieve a user's chosen song in the bandaoke queue
  Future retrieveChosenSong(String uid) async {
    String chosenSong = '';

    // Retrieve the bandaoke queue document
    await bandaokeQueueCollection
        .where('id', isEqualTo: 'Z4NtbE7IQ2vp32WHkpYY')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        BandaokeQueue bandaokeQueue = bandaokeQueueFromSnapshot(doc);

        // If there are any queued members
        if (bandaokeQueue.queuedMembers!.isNotEmpty) {

          for (int index = 0; index < bandaokeQueue.queuedMembers!.length; index++) {
            // Find the user's map in the array
            if (bandaokeQueue.queuedMembers![index]['uid'] == uid) {
              // Retrieve the user's chosen song from this map
              chosenSong = bandaokeQueue.queuedMembers![index]['songTitle'];
            }
          }

        }
      })
    });

    return chosenSong;
  }


  // Update a song title in the bandaoke queue
  Future changeSong(String uid, String newSongTitle) async {
    // Retrieve the Bandaoke Queue document
    await bandaokeQueueCollection
        .where('id', isEqualTo: 'Z4NtbE7IQ2vp32WHkpYY')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        BandaokeQueue bandaokeQueue = bandaokeQueueFromSnapshot(doc);

        // Retrieve the existing array from the document
        var updatedArray = bandaokeQueue.queuedMembers!;

        // Update the array
        // Do not need to worry about duplicates being renamed here as duplicates
        // cannot be created in the first place
        for (var itemIndex = 0 ; itemIndex < updatedArray.length; itemIndex++) {
          if (updatedArray[itemIndex]['uid'] == uid) {
            updatedArray[itemIndex]['songTitle'] = newSongTitle;
          }
        }

        // Write the updated array to the document
        bandaokeQueueCollection.doc('Z4NtbE7IQ2vp32WHkpYY').update({"queuedMembers": updatedArray});
      })
    });
  }


  // Return a ComedyNightSchedule Model object from a given
  // ComedyNightSchedule snapshot
  ComedyNightSchedule comedyNightScheduleFromSnapshot(var snapshotList) {
    return ComedyNightSchedule(
      id: snapshotList['id'],
      date: snapshotList['date'],
      comedians: snapshotList['comedians'],
    );
  }


  // Create a new comedian inside of the "comedians" array of maps inside of the
  // ComedyNightSchedule collection document
  Future createComedian(Comedian comedian) async {

    // Add the comedian's details to a map
    var newEntryMap = {
      'id': _generateID(),
      'name': comedian.name,
      'startTime': comedian.startTime,
      'endTime': comedian.endTime,
      'facebook': comedian.facebook,
      'instagram': comedian.instagram,
      'twitter': comedian.twitter,
      'snapchat': comedian.snapchat
    };

    // Create a one-element array containing the map
    // (Since the comedians property in the document is an array of maps)
    var newEntryArray = [newEntryMap];

    // Add this new item to the array in the document by conducting a union
    // between the two arrays
    comedyNightScheduleCollection.doc('cdw979CbT0Uo5QKDejsh').update(
        {"comedians": FieldValue.arrayUnion(newEntryArray)}
    );
  }


  // Edit a comedian's details inside of the "comedians" array of maps inside of
  // the ComedyNightSchedule collection document
  Future editComedian(Comedian comedian) async {

    // Retrieve the ComedyNightSchedule document
    await comedyNightScheduleCollection
        .where('id', isEqualTo: 'cdw979CbT0Uo5QKDejsh')
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      // For the found document,
      querySnapshot.docs.forEach((doc) async {

        ComedyNightSchedule comedyNightSchedule =
                                          comedyNightScheduleFromSnapshot(doc);

        // Retrieve the existing array from the document
        var updatedArray = comedyNightSchedule.comedians!;

        // Update the array
        // Do not need to worry about duplicates being renamed here as duplicates
        // cannot be created in the first place
        for (var itemIndex = 0 ; itemIndex < updatedArray.length; itemIndex++) {
          if (updatedArray[itemIndex]['id'] == comedian.id) {
            updatedArray[itemIndex]['name'] = comedian.name;
            updatedArray[itemIndex]['startTime'] = comedian.startTime;
            updatedArray[itemIndex]['endTime'] = comedian.endTime;
            updatedArray[itemIndex]['facebook'] = comedian.facebook;
            updatedArray[itemIndex]['instagram'] = comedian.instagram;
            updatedArray[itemIndex]['twitter'] = comedian.twitter;
            updatedArray[itemIndex]['snapchat'] = comedian.snapchat;
          }
        }

        // Write the updated array to the document
        comedyNightScheduleCollection.doc('cdw979CbT0Uo5QKDejsh').update({"comedians": updatedArray});
      })
    });

  }


  // Delete a comedian inside of the "comedians" array of maps inside of the
  // ComedyNightSchedule collection document
  Future deleteComedian(Comedian comedian) async {

    // Add the comedian's details to a map
    var entryMap = {
      'id': comedian.id,
      'name': comedian.name,
      'startTime': comedian.startTime,
      'endTime': comedian.endTime,
      'facebook': comedian.facebook,
      'instagram': comedian.instagram,
      'twitter': comedian.twitter,
      'snapchat': comedian.snapchat
    };

    // Create a one-element array containing the map
    // (Since the comedians property in the document is an array of maps)
    var entryArray = [entryMap];

    // Delete this map from the array
    comedyNightScheduleCollection.doc('cdw979CbT0Uo5QKDejsh').update(
        {"comedians": FieldValue.arrayRemove(entryArray)}
    );
  }


  // Update the Comedy Night's scheduled DateTime
  Future updateComedyDate(DateTime newDate) async {
    comedyNightScheduleCollection.doc('cdw979CbT0Uo5QKDejsh').update(
        {"date": newDate}
    );
  }
}
