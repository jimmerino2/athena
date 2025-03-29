import 'package:athena/services/auth.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  Future<void> addUser(String uid, String name) async {
    try {
      if (uid.isNotEmpty && name.isNotEmpty) {
        await db.collection('users').doc(uid).set({
          'name': name,
          'uid': uid,
        }, SetOptions(merge: true));
      } else {
        print('User ID or name is empty');
      }
    } catch (e) {
      print('error adding user $e');
    }
  }

  Future<String> getChosenJob(String uid) async {
    try {
      final docRef = db.collection("quizzes").doc(uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        return "Document doesn't exist";
      }

      final data = doc.data() as Map<String, dynamic>;
      return data['chosenJob'] ?? "No course data found";
    } catch (e) {
      print("Error getting document: $e");
      return "Error: $e";
    }
  }
}
