import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> getUserFullName() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? currentUser = auth.currentUser;

  if (currentUser == null) {
    print('User is not logged in. UID is null.');
    return 'Guest';
  }

  final uid = currentUser.uid;
  print('Current UID: $uid');

  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final docSnapshot = await docRef.get();

  print('Document exists: ${docSnapshot.exists}');

  if (!docSnapshot.exists) {
    print('No document found for this UID in the users collection.');
    return 'Guest';
  }

  final data = docSnapshot.data();
  print('User data from Firestore: $data');

  final firstName = data?['fName'] ?? '';
  final lastName = data?['lName'] ?? '';
  return '$firstName $lastName';
}