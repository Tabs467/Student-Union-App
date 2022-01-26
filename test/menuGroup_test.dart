import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:student_union_app/screens/menu/menu.dart';

class MockFirebase extends Mock implements FirebaseFirestore{

}

void main() {
  final MockFirebase mockFirebase = MockFirebase();

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Default route is to the food/drink menu
    runApp(MaterialApp(
      initialRoute: '/menu',
      routes: {
        '/menu': (context) => Menu(),
      },
    ));
  });

  testWidgets('Given correct MenuGroups on Menu page',
      (WidgetTester tester) async {

    // Assemble

        FirebaseFirestore;


    await tester.pumpWidget(const MaterialApp(home: Menu()));

    // Act

    // Assert

    // Find exactly one text widget per Menu Group
    expectLater(find.text('Drinks'), findsOneWidget);

    expectLater(find.text('Mains'), findsOneWidget);

    expectLater(find.text('Desserts'), findsOneWidget);

    expectLater(find.text('Sides'), findsOneWidget);
  });
}
