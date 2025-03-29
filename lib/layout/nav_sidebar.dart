import 'package:athena/screens/courses/courses.dart';
import 'package:athena/screens/gemini_test/gemini.dart';
import 'package:athena/screens/joblistings/joblistings.dart';
import 'package:athena/screens/questions/questions.dart';
import 'package:flutter/material.dart';
import 'package:athena/services/auth.dart';
import 'package:athena/services/firestore.dart';

class NavSidebarLayout extends StatefulWidget {
  const NavSidebarLayout({super.key});

  @override
  _NavSidebarLayoutState createState() => _NavSidebarLayoutState();
}

class _NavSidebarLayoutState extends State<NavSidebarLayout> {
  int selectedIndex = 0;
  final List<Widget> screens = [const CoursesScreen(), const GeminiScreen(), const QuestionScreen(), const JobListingsScreen()];
  List<Map<String, dynamic>> selections = [
    {'title': "Courses", 'icon': Icon(Icons.library_books)},
    {'title': "Gemini Test", 'icon': Icon(Icons.smart_toy)},
    {'title': "Question/Quizz", 'icon': Icon(Icons.smart_toy)},
    {'title': "Job Listings", 'icon': Icon(Icons.list)},
  ];

  @override
  Widget build(BuildContext context) {
    final String userName = AuthService().user?.displayName ?? "User";
    final String uid = AuthService().user?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Athena'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Athena'),
                  Text("Hello $userName"),
                  FutureBuilder(
                    future: FirestoreService().getChosenJob(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      return Text("Chosen job: ${snapshot.data}");
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async => await AuthService().signOut(),
                    child: Text("Sign Out"),
                  ),
                ],
              ),
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
