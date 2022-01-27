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

  // Some FireStore access requires the authentication service to determine
  // the currently logged-in user's UID
  final AuthenticationService _auth = AuthenticationService();

  // Create or update user information into the Users collection
  // in the database
  Future updateUser(String uid, String email, String name, String teamName,
      int wins, bool admin) async {
    // If a document with the given uid doesn't exist yet in the database
    // it will be created
    return await userCollection.doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'teamName': teamName,
      'wins': wins,
      'admin': admin,
    });
  }

  // Create a CurrentUser object based on results from a query to the
  // Users collection
  CurrentUser? _userFromQuery(String uid, String email, String name,
      String teamName, int wins, bool admin) {
    return CurrentUser(
        uid: uid,
        email: email,
        name: name,
        teamName: teamName,
        wins: wins,
        admin: admin);
  }

  // Query to return a given user's data
  Future getUserData() async {
    String uid = _auth.currentUID()!;
    String email = '';
    String name = '';
    String teamName = '';
    int wins = 0;
    bool admin = false;

    await userCollection
        .where('uid', isEqualTo: uid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                email = doc["email"];
                name = doc["name"];
                teamName = doc["teamName"];
                wins = doc["wins"];
                admin = doc["admin"];
              })
            });

    return _userFromQuery(uid, email, name, teamName, wins, admin);
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

  // Insert a question into the Questions collection in the database
  Future createQuestion(
      String quizID,
      int questionNumber,
      String questionText,
      String correctAnswer,
      String answerA,
      String answerB,
      String answerC,
      String answerD) async {
    // If document with questionID does not already exist it will be created
    return await questionCollection.doc().set({
      'quizID': quizID,
      'questionNumber': questionNumber,
      'questionText': questionText,
      'correctAnswer': correctAnswer,
      'answerA': answerA,
      'answerB': answerB,
      'answerC': answerC,
      'answerD': answerD,
    });
  }

  // Return a stream of the quizzes inside the Quizzes collection
  Stream<QuerySnapshot> get quizzes {
    return quizCollection.snapshots();
  }

  // Return a stream of the questions inside the Questions collection
  Stream<QuerySnapshot> get questions {
    return questionCollection.snapshots();
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

  // Mark the inputted quiz as inactive and set the non active quiz marker in the
  // database to true
  Future endQuiz(String quizID) async {
    // Mark the Quiz document that is used to mark that there
    // isn't a quiz currently active as active
    quizCollection.doc('cy7RWIJ3VGIXlHSM1Il8').update({"isActive": true});

    // Mark the inputted quiz document as inactive
    return quizCollection
        .doc(quizID)
        .update({"isActive": false, "quizEnded": true, "currentQuestion": 1});
  }

  // Move an inputted quiz to its next question and mark whether the quiz has ended or not
  Future nextQuestion(
      String quizID, int currentQuestionNumber, int questionCount) async {
    currentQuestionNumber++;

    // If the previous question was the last question in the quiz
    if (currentQuestionNumber > questionCount) {
      // Also mark the quiz as ended in the database
      return quizCollection.doc(quizID).update(
          {"currentQuestion": currentQuestionNumber, "quizEnded": true});
    }
    // Otherwise
    else {
      // Just increment the current question number variable on the inputted Quiz Document
      return quizCollection
          .doc(quizID)
          .update({"currentQuestion": currentQuestionNumber});
    }

    // Tally everyone's score with currentQuestionCorrect
    // (all score docs with quizID)
    // add points depending on stuff found in submit answer
    // so could refactor into a function here when finished

    // Set everyone's currentQuestionCorrect to False
  }


  // Score document is created or updated to store whether the
  // currently logged-in user has the correct answer currently selected on the
  // current question in the currently active quiz.
  Future submitAnswer(String answer) async {

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
            .update({'currentQuestionCorrect': true});
      } else {
        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': false});
      }
    }
    // Otherwise, if creating a new Score document
    else {
      // Create a score doc with an auto generated id

      // Generate id by creating a String from generating 20 random numbers
      // which correspond to characters in the _chars constant
      const _chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      scoreID = String.fromCharCodes(Iterable.generate(
          20, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));


      // Create the Score document with the currentQuestionCorrect boolean
      // storing whether the user has the correct answer currently selected
      if (answerCorrect) {
        await scoreCollection.doc(scoreID).set({
          'id': scoreID,
          'quizID': quizID,
          'userID': userID,
          'score': 0,
          'currentQuestionCorrect': true
        });
      } else {
        await scoreCollection.doc(scoreID).set({
          'id': scoreID,
          'quizID': quizID,
          'userID': userID,
          'score': 0,
          'currentQuestionCorrect': false
        });
      }
    }
  }
}
