import 'package:flutter/material.dart';
import 'package:athena/layout/bottom_nav.dart';
import 'package:athena/services/auth.dart';

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
  const CoursesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await AuthService().signOut();
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        },
        child: Text('Sign Out'),
      ),
    );
  }
}
