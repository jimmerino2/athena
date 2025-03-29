import 'package:athena/screens/courses/courses.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [CoursesScreen(), Placeholder(), Placeholder()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.locationPin, size: 20),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bookBookmark, size: 20),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bell, size: 20),
            label: 'Updates',
          ),
        ],
        fixedColor: Colors.deepPurple[200],
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
