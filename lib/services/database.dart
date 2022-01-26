import 'authentication.dart';
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
  }
}
