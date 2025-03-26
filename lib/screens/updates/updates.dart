import 'package:flutter/material.dart';
import 'package:athena/layout/bottom_nav.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Updates')),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
