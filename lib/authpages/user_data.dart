import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String? currentUsername;
String? currentUserRole;

Future<void> fetchAndStoreUserData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Store username and role in global variables
        currentUsername = userDoc.data()?['username'];
        currentUserRole = userDoc.data()?['role'];
        print("Fetched username: $currentUsername");
        print("Fetched role: $currentUserRole");
      } else {
        print("User document does not exist.");
      }
    } else {
      print("No user is currently logged in.");
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
}

