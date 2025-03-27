import 'package:athena/screens/gemini_test/gemini.dart';
import 'package:athena/screens/questions/question_pages.dart';
import 'package:athena/screens/questions/questions.dart';
import 'package:athena/screens/home/home.dart';
import 'package:athena/screens/login/login.dart';
import 'package:athena/screens/profile/profile.dart';
import 'package:athena/screens/courses/courses.dart';
import 'package:athena/screens/updates/updates.dart';
import 'package:athena/screens/saved/saved.dart';

var appRoutes = {
  "/": (context) => const Home(),
  "/login": (context) => const LoginScreen(),
  "/profile": (context) => const ProfileScreen(),
  "/courses": (context) => const CoursesScreen(),
  "/questions": (context) => const QuestionScreen(),
  "/updates": (context) => const UpdatesScreen(),
  "/saved": (context) => const SavedScreen(),
  "/gemini": (context) => const GeminiScreen(),
  "/questionPages": (context) => const QuestionPages(),
};
