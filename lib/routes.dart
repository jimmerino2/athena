import 'package:athena/questions/questions.dart';
import 'package:athena/home/home.dart';
import 'package:athena/login/login.dart';
import 'package:athena/profile/profile.dart';
import 'package:athena/courses/courses.dart';
import 'package:athena/updates/updates.dart';
import 'package:athena/saved/saved.dart';

var appRoutes = {
  "/": (context) => const Home(),
  "/login": (context) => const LoginScreen(),
  "/profile": (context) => const ProfileScreen(),
  "/courses": (context) => const CoursesScreen(),
  "/questions": (context) => const QuestionScreen(),
  "/updates": (context) => const UpdatesScreen(),
  "/saved": (context) => const SavedScreen(),
};
