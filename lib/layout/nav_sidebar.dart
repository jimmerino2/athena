import 'package:athena/screens/courses/courses.dart';
import 'package:athena/screens/gemini_test/gemini.dart';
import 'package:athena/screens/joblistings/joblistings.dart';
import 'package:athena/screens/profile/profile.dart';
import 'package:athena/screens/questions/questions.dart';
import 'package:athena/screens/resume/resume.dart';
import 'package:flutter/material.dart';
import 'package:athena/services/auth.dart';

class NavSidebarLayout extends StatefulWidget {
  const NavSidebarLayout({super.key, this.index = 0, this.isNewLayout = false});
  final int index;
  final bool isNewLayout;

  @override
  _NavSidebarLayoutState createState() => _NavSidebarLayoutState();
}

class _NavSidebarLayoutState extends State<NavSidebarLayout> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.isNewLayout ? widget.index : 0;
  }

  final List<Widget> screens = [
    const CoursesScreen(),
    const GeminiScreen(),
    const QuestionScreen(),
    const JobListingsScreen(),
    const ResumeScreen(),
    const ProfileScreen(),
  ];
  List<Map<String, dynamic>> selections = [
    {'title': "Courses", 'icon': Icon(Icons.library_books)},
    {'title': "Gemini Test", 'icon': Icon(Icons.smart_toy)},
    {'title': "Quiz", 'icon': Icon(Icons.smart_toy)},
    {'title': "Job Listings", 'icon': Icon(Icons.list)},
    {'title': "Resume Review", 'icon': Icon(Icons.list)},
  ];

  final int profileIndex = 5; // Temporary. Please update if adding new screens.

  @override
  Widget build(BuildContext context) {
    ProfileRepository profile = ProfileRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Athena')),
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  // decoration: BoxDecoration(color: Colors.blue),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Athena',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40.0,
                            backgroundImage: NetworkImage(profile.photoUrl),
                            backgroundColor: Colors.grey,
                          ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.userName,
                                  style: TextStyle(fontSize: 18.0),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                FutureBuilder(
                                  future: profile.chosenJob,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "...",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14.0,
                                        ),
                                      );
                                    }
                                    return Text(
                                      "${snapshot.data}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 14.0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.settings_outlined),
                            onPressed: () {
                              setState(() {
                                selectedIndex = profileIndex;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      Spacer(),
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
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      "Sign Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async => await AuthService().signOut(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: screens[selectedIndex],
    );
  }
}
