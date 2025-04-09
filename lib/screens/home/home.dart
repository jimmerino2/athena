import 'package:athena/layout/nav_sidebar.dart';
import 'package:athena/screens/courses/courses.dart';
import 'package:athena/screens/joblistings/joblistings.dart';
import 'package:athena/screens/profile/profile.dart';
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


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        ProfileRepository().chosenJob,
        CoursesRepository.fetchCourses(),
        JobListingRepository.fetchJobListing(),
      ]), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error");
        } else {
          final String chosenJob = snapshot.data![0] as String;
          final List<Course> courses = snapshot.data![1] as List<Course>;
          final List<Job> jobs = snapshot.data![2] as List<Job>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text.rich(
                    TextSpan(
                      text: "You are going to be a ",
                      children: <TextSpan>[
                        TextSpan(
                          text: chosenJob,
                          style: TextStyle(fontWeight: FontWeight.bold)
                        ),
                        TextSpan(text: "!"),
                      ]
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      // fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text("Courses", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
                      Spacer(),
                      TextButton(
                        child: Text("View All"),
                        onPressed: () {}, 
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    SmallCourseCard(course: courses[0]),
                    // Text(courses[2].title),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      // child: Text(courses[1].title),
                      child: SmallCourseCard(course: courses[1]),
                    ),
                  ],
                ),
            
                SizedBox(height: 20,),
            
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text("Job Listings", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
                      Spacer(),
                      TextButton(
                        child: Text("View All"),
                        onPressed: () {}, 
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SimpleJobCard(job: jobs[0]),
                      // Text(courses[2].title),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black, Colors.transparent],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        // child: Text(courses[1].title),
                        child: SimpleJobCard(job: jobs[1]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }
    );
  }
}