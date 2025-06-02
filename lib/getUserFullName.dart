import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getUserFullName() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return '';
    }

    // Get user document from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      return '';
    }

    final userData = userDoc.data();
    if (userData == null) {
      return '';
    }

    final firstName = userData['firstName'] as String? ?? '';
    final lastName = userData['lastName'] as String? ?? '';

    if (firstName.isEmpty && lastName.isEmpty) {
      // If no name is found in Firestore, try to get display name from Firebase Auth
      return user.displayName ?? '';
    }

    return '$firstName $lastName'.trim();
  } catch (e) {
    print('Error getting user name: $e');
    return '';
  }
}