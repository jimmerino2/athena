import 'dart:async';
import 'package:athena/screens/profile/profile.dart';
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

  Future<void> addResults({
    required String uid,
    DateTime? dateTime,
    bool isStudent = false,
    String? educationLevel,
    List? educationScore,
    List? interests,
    String? dream,
    List? suggestions,
    String? chosenJob,
  }) async {
    try {
      if (uid.isNotEmpty) {
        await db.collection('quizzes').doc(uid).set({
          'dateTime': dateTime,
          'isStudent': isStudent,
          'educationLevel': educationLevel,
          'educationScore': educationScore,
          'interests': interests,
          'dream': dream,
          'suggestions': suggestions,
          'chosenJob': chosenJob,
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
      final docRef = db.collection("users").doc(uid);
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

  void setChosenJob(String uid, String job) async {
    print(uid);
    print(job);
    final docRef = db.collection("users").doc(uid);
    docRef
        .update({'chosenJob': job})
        .then(
          (value) => print("DocumentSnapshot successfully updated!"),
          onError: (e) => print("Error updating document $e"),
        );

    ProfileRepository().refreshProfile();
  }
}
