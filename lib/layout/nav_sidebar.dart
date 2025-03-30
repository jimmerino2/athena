import 'package:athena/screens/courses/courses.dart';
import 'package:athena/screens/gemini_test/gemini.dart';
import 'package:athena/screens/questions/questions.dart';
import 'package:flutter/material.dart';

class NavSidebarLayout extends StatefulWidget {
  const NavSidebarLayout({super.key});

  @override
  _NavSidebarLayoutState createState() => _NavSidebarLayoutState();
}

class _NavSidebarLayoutState extends State<NavSidebarLayout> {
  int selectedIndex = 0;
  final List<Widget> screens = [
    const CoursesScreen(),
    const GeminiScreen(),
    const QuestionScreen(),
  ];

  List<Map<String, dynamic>> selections = [
    {'title': "Courses", 'icon': Icon(Icons.library_books)},
    {'title': "Gemini Test", 'icon': Icon(Icons.smart_toy)},
    {'title': "Quiz", 'icon': Icon(Icons.abc)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Athena'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Athena'),
            ),
            for (var item in selections.asMap().entries)
              ListTile(
                leading: item.value['icon'],
                title: Text(item.value['title']),
                selected: selectedIndex == item.key,
                onTap: () {
                  setState(() {
                    selectedIndex = item.key;
                    Navigator.of(context).pop();
                  });
                },
              ),
          ],
        ),
      ),
      body: screens[selectedIndex],
    );
  }
}
