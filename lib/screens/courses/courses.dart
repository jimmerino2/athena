import 'package:flutter/material.dart';
import 'package:athena/layout/bottom_nav.dart';
import 'package:athena/services/auth.dart';
import 'package:athena/services/firestore.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(children: [Expanded(child: CoursesContent())]),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

class CoursesContent extends StatelessWidget {
  CoursesContent({super.key});
  final String userName = AuthService().user?.displayName ?? "User";
  final String uid = AuthService().user?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil("/", (route) => false);
            },
            child: Text('Sign Out'),
          ),
          Text("Hello $userName"),
          FutureBuilder(
            future: FirestoreService().getChosenJob(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return Text("Your chosen job is ${snapshot.data}");
            },
          ),
        ],
      ),
    );
  }
}
