import 'dart:convert';
import 'package:athena/services/auth.dart';
import 'package:athena/services/firestore.dart';
import 'package:flutter/material.dart';
// import 'package:athena/layout/bottom_nav.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';

// class CoursesScreen extends StatelessWidget {
//   const CoursesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(children: [Expanded(child: CoursesContent())]),
//       bottomNavigationBar: BottomNavBar(),
//     );
//   }
// }

class Course {
  final String title;
  final String author;
  final String description;
  final String url;

  Course({
    required this.title,
    required this.author,
    required this.description,
    required this.url,
  });

  factory Course.fromList(List<String> list) => Course(
    title: list[0],
    author: list[1],
    description: list[2],
    url: list[3],
  );
}

class CoursesRepository {
  static final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyD2Vi6H-b2WpI7wqGNerCtPeFJRws65JEc',
  );

  static Future<List<Course>>? _courses;

  static Future<List<Course>> _fetchCourses() async {
    String job = await FirestoreService().getChosenJob(
      AuthService().user?.uid ?? "",
    );
    String prompt =
        """Provide a list of REAL online courses from reputable educational platforms, that a student interested in becoming a $job could take, in JSON format. 
        The JSON should be an array of arrays, where each inner array represents a course and contains the following elements in order: 
        Title, Author or Provider, Summary description, URL to the course.
        Only provide courses that are verifiable as currently available. 
        Do not add any comments.""";
        
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    // Regex: Find first '[', match until the first '`' (Captures JSON section). This is to ignore any additional text Gemini adds after the JSON.
    Match? match = RegExp(
      r'(\[\s*[\s\S]*?)\s*(?=`)',
    ).firstMatch(response.text!);

    if (match == null) {
      return Future.error("Response text formatted incorrectly");
    }
    final jsonText = match.group(1)!.trim();
    return (jsonDecode(jsonText) as List)
        .map((e) => Course.fromList(List<String>.from(e)))
        .toList();
  }

  static Future<List<Course>> fetchCourses() {
    _courses ??= _fetchCourses();

    return _courses!;
  }

  static Future<List<Course>> refreshCourses() {
    _courses = _fetchCourses();
    return _courses!;
  }
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text("Courses", style: TextStyle(fontSize: 28)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                onPressed:
                    () => setState(() {
                      CoursesRepository.refreshCourses();
                    }),
                icon: Icon(Icons.refresh),
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: CoursesRepository.fetchCourses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // handle error
              return Text("Error: ${snapshot.error}");
            } else {
              List<Course> courses = snapshot.data!;
              return Expanded(
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    Course course = courses[index];
                    return LargeCourseCard(course: course);
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class LargeCourseCard extends StatelessWidget {
  const LargeCourseCard({super.key, required this.course});

  final Course course;
  // final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              course.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(course.author),
          ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/600x400/png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(course.description),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
                Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
                ElevatedButton(
                  // onPressed: () {},
                  onPressed: () async => await launchUrl(Uri.parse(course.url)),
                  child: Text("Open"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
