import 'package:athena/screens/questions/questions.dart';
import 'package:athena/services/auth.dart';
import 'package:athena/services/firestore.dart';
import 'package:flutter/material.dart';

class ProfileRepository {
  late String uid;
  late String userName;
  late String photoUrl;
  late String location;
  late Future<String> chosenJob;

  static final ProfileRepository _instance = ProfileRepository._internal();

  factory ProfileRepository() => _instance;

  ProfileRepository._internal() {
    fetchProfile();
  }

  bool _hasData = false;

  void fetchProfile() {
    if (!_hasData) {
      userName = AuthService().user?.displayName ?? "User";
      photoUrl = AuthService().user?.photoURL ?? "None";
      uid = AuthService().user?.uid ?? "";
      location = "Location, Place";
      chosenJob = FirestoreService().getChosenJob(uid);

      _hasData = true;
    }
  }

  void refreshProfile() {
    _hasData = false;
    fetchProfile();
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileRepository profile = ProfileRepository();

    return Stack(
      children: [
        ListView(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 80.0,
                  backgroundImage: NetworkImage(profile.photoUrl),
                  backgroundColor: Colors.grey,
                ),
            
                SizedBox(height: 10),
            
                Text(profile.userName, style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            
                FutureBuilder(
                  future: profile.chosenJob,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("...", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24.0));
                    }
                    return Text("${snapshot.data}", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24.0), overflow: TextOverflow.ellipsis);
                  },
                ),
            
                InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.blue,),
                      SizedBox(width: 4.0),
                      Text(profile.location, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue)),
                    ],
                  ),
                  onTap: () {},
                )
              ],
            ),

            Divider(height: 28, indent: 20, endIndent: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MenuItemButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionScreen())), // Move quiz here in the future
                trailingIcon: Icon(Icons.arrow_forward),
                child: Text("Redo Quiz", style: TextStyle(fontSize: 16),),
              ),
            )
          ],
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async => await AuthService().signOut(), 
            ),
          ),
        ),
      ],
    );
  }
}
