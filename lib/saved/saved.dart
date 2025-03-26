import 'package:flutter/material.dart';
import 'package:athena/shared/bottom_nav.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved')),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
