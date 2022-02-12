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


  // Query to return the logged-in user's data
  Future getLoggedInUserData() async {
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


  // Query to return a user's data
  Future getUserData(uid) async {
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


  // Update the currently logged-in user's Team Name
  Future updateUserTeamNameDetails(teamName) async {
    String uid = _auth.currentUID()!;
    return userCollection.doc(uid).update({"teamName": teamName});
  }


  // Update a user's number of pub quiz wins to include one more win
  Future addWin(String uid) async {
    // Retrieve the given user's data
    CurrentUser winningUser = await getUserData(uid) as CurrentUser;

    // Calculate the new amount of wins
    int newWins = winningUser.wins + 1;

    // Update the user document to store the new number of wins
    await userCollection.doc(uid).update({
      'wins': newWins,
    });
  }


  // Generate id by creating a String from generating 20 random numbers
  // which correspond to characters in the _chars constant
  String _generateID() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return String.fromCharCodes(Iterable.generate(
        20, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
  }


  // Insert a new question document into the Questions collection
  // Whilst also incrementing the total number of questions contained within
  // the new question's quiz
  Future createQuestion(
      String quizID,
      int questionNumber,
      String questionText,
      String correctAnswer,
      String answerA,
      String answerB,
      String answerC,
      String answerD) async {

    String id = _generateID();

    // Increment total questions in the new questions' quiz by one
    await quizCollection
        .where('id', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) =>
    {
      querySnapshot.docs.forEach((doc) async {
        int totalQuestions = doc["questionCount"];

        await quizCollection.doc(quizID).update({
          "questionCount": (totalQuestions + 1),
        });
      })
    });

    // Create the question document
    return await questionCollection.doc(id).set({
      'id': id,
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
        int questionNumber = doc["questionNumber"];
        String quizID = doc["quizID"];

        // Fetch all questions after the deleted question in the quiz
        await questionCollection
            .where('quizID', isEqualTo: quizID)
            .where('questionNumber', isGreaterThan: questionNumber)
            .get()
            .then((QuerySnapshot querySnapshot) =>
        {
          querySnapshot.docs.forEach((doc) async {

            // Decrement their question number by one
            String questionID = doc["id"];
            int currentQuestionNumber = doc["questionNumber"];
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
            int totalQuestions = doc["questionCount"];

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


  // Update a question document in the Questions collection
  Future updateQuestion(
      String id,
      String answerA,
      String answerB,
      String answerC,
      String answerD,
      String correctAnswer,
      String questionText) async {

    return await questionCollection.doc(id).update({
      "answerA": answerA,
      "answerB": answerB,
      "answerC": answerC,
      "answerD": answerD,
      "correctAnswer": correctAnswer,
      "questionText": questionText
    });

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

    return quizCollection.doc(id).delete();
  }


  // Update a quiz document's quizTitle property inside of the
  // Quizzes collection
  Future updateQuiz(String id, String quizTitle) async {
    return await quizCollection.doc(id).update({"quizTitle": quizTitle});
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


  // Mark the inputted quiz as inactive and set the non active quiz marker in
  // the database to true
  // Also reset all the currentQuestionCorrect booleans in the
  // Scores collection for the active quiz to false
  // Also for each winning user of the quiz add one win to their User document
  // in the Users collection
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
          String userID = doc["userID"];
          await addWin(userID);
        })
      });
    }

    // Reset all the currentQuestionCorrect booleans for the active quiz to
    // false
    // To allow this quiz to be restarted without accidentally giving out
    // any points.
    return scoreCollection
        .where('quizID', isEqualTo: quizID)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) async {
        String scoreID = doc["id"];
        await scoreCollection
            .doc(scoreID)
            .update({'currentQuestionCorrect': false});
      })
    });
  }


  // Move an inputted quiz to its next question and mark whether the quiz
  // has ended or not

  // Also add 10 points to each score document with the currentQuestionCorrect
  // boolean set to true
  // And then set each one of these booleans to false so they are prepared
  // for the next question.

  // This function also resets each score to zero if it is the start of the
  // quiz in case this quiz has been played before by the users taking part
  Future nextQuestion(
      String quizID, int currentQuestionNumber, int questionCount) async {

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
          String scoreID = doc["id"];
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
        String scoreID = doc["id"];
        bool answerCorrect = doc["currentQuestionCorrect"];
        int currentScore = doc["score"];

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
      })
    });
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
      // Create a score doc with an auto generated id of 20 characters
      scoreID = _generateID();

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


  // Insert a new Menu Group document into the MenuGroup collection
  Future createMenuGroup(String name) async {
    String id = _generateID();

    // Create the MenuGroup document
    return await menuGroupCollection.doc(id).set({
      'id': id,
      'name': name,
    });
  }


  // Update a Menu Group's document's name property inside of the
  // MenuGroup collection
  Future updateMenuGroup(String id, String name) async {
    return await menuGroupCollection.doc(id).update({"name": name});
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


  // Insert a new Menu Sub Group document into the MenuSubGroup collection
  Future createMenuSubGroup(String menuGroupID, String name) async {
    String id = _generateID();

    // Create the MenuSubGroup document
    return await menuSubGroupCollection.doc(id).set({
      'MenuGroupID': menuGroupID,
      'name': name,
      'id': id,
      'MenuItems': <String>[],
    });
  }


  // Update a Menu Sub Group's document's name property inside of the
  // MenuSubGroup collection
  Future updateMenuSubGroup(String id, String name) async {
    return await menuSubGroupCollection.doc(id).update({"name": name});
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

        // Create a list containing one element that describes the new item to
        // be added
        var newItem = [itemDetails];

        // Add this new item to the array by conducting a union between to the
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

        // Create a list containing one element that describes the item to be
        // deleted
        var deletedItem = [itemDetails];

        // Delete this item from the array
        // Do not need to worry about duplicates being deleted here as duplicates
        // cannot be created within Sub Groups in the first place
        menuSubGroupCollection.doc(subGroupID).update({"MenuItems": FieldValue.arrayRemove(deletedItem)});
      })
    });
  }
}
