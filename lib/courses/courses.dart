import 'package:flutter/material.dart';
import 'package:athena/shared/bottom_nav.dart';
import 'package:athena/services/auth.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: ElevatedButton(
        onPressed: () async {
          await AuthService().signOut();
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
        },
        child: Text('signout'),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
