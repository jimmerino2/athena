import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      onTap: (int idx) {
        switch (idx) {
          case 0:
            Navigator.pushNamed(context, "/courses");
            break;
          case 1:
            Navigator.pushNamed(context, "/saved");
            break;
          case 2:
            Navigator.pushNamed(context, "/updates");
        }
      },
    );
  }
}
