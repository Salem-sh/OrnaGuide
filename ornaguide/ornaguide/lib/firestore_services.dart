import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? user = FirebaseAuth.instance.currentUser;


  // Save Search
  Future<void> savePlantSearch(Map<String, String> plantInfo) async {
  try {
    // Add null check for user
    if (user == null) {
      throw Exception("User not authenticated!");
    }

    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('history')
        .add({
          ...plantInfo,
          'timestamp': FieldValue.serverTimestamp(),
        });
  } catch (e) {
    print('Error saving search: $e');
    throw Exception('Failed to save search');
  }
}


  // Save Plant
  Future<void> savePlantHistory(Map<String, String> plantData) async {
  try {
    if (user == null) throw Exception("User not authenticated");
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('history')
        .add({
          'common_name': plantData['common_name'],
          'plant_family': plantData['plant_family'],
          'description': plantData['description'],
          'ornamental_type': plantData['ornamental_type'],
          'diseases': plantData['diseases'],
          'care_schedule': plantData['care_schedule'],
          'timestamp': FieldValue.serverTimestamp(),
          'weekly_watering': plantData['weekly_watering'],
        });
  } catch (e) {
    print('Error saving history: $e');
    rethrow;
  }
}

  // Upload Image
  Future<String> uploadImage(File image) async {
    try {
      String fileName = 'plant${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('plant_images/$fileName');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  // Get History
  Stream<QuerySnapshot> getHistoryStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteHistoryItem(String docId) async {
  try {
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('history')
        .doc(docId)
        .delete();
  } catch (e) {
    print('Error deleting item: $e');
    throw Exception('Failed to delete item');
  }
}
}