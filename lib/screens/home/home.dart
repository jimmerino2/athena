import 'package:athena/layout/nav_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:athena/screens/login/login.dart';
import 'package:athena/services/auth.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('error'));
        } else if (snapshot.hasData) {
          return const NavSidebarLayout();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
