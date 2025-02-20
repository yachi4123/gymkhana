import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymkhana_app/authpages/user_data.dart';
import 'post-event.dart';
import '../constants/colours.dart';
import 'home.dart';
import 'authpages/login.dart';
import 'search.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user info
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    HomePage(), // Your home page
    SearchPage(), // Placeholder for search page
    ProfilePage(), // Current profile page
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allows resizing when the keyboard opens
      bottomNavigationBar: NavigationBar(
        backgroundColor: CustomColors.backgroundColor,
        selectedIndex: _selectedIndex,
        indicatorColor: CustomColors.secondaryColor,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined, color: Colors.white),
            selectedIcon: Icon(Icons.search, color: Colors.white),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white),
            selectedIcon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
      backgroundColor: CustomColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: CustomColors.backgroundColor,
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height*0.8,
          ),
          child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Avatar
              CircleAvatar(
                radius: screenHeight*0.1,
                backgroundColor: Colors.grey[800],
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username Field
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "Username",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: CustomColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: currentUsername ?? 'Username',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Email Field
                  Container(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "Email",
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: CustomColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: user?.email ?? 'Email',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
  
              // Post a New Event Button
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => PostEventPage()),
              //     );
              //   },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: CustomColors.secondaryColor,
              //     padding: const EdgeInsets.symmetric(
              //         vertical: 16, horizontal: 32),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(25),
              //     ),
              //   ),
              //   child: Text(
              //     'Post a New Event',
              //     style: TextStyle(color: Colors.white, fontSize: 16),
              //   ),
              // ),
              // View Your Events Link

            //   Container(
            //   margin: EdgeInsets.only(
            //     top: screenHeight * 0.02,
            //     right: screenWidth * 0.05,
            //   ),
            //   alignment: Alignment.centerRight,
            //   child: InkWell(
            //     onTap: () {
            //
            //     },
            //     child: Text(
            //       'View Your Events ->',
            //       style: TextStyle(color: CustomColors.secondaryColor),
            //     ),
            //   ),
            // ),
              
            Spacer(),
              // Logout Button
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.017,
                      horizontal: screenWidth * 0.2,
                    ),
                  ),
                onPressed: () async {
                  bool shouldLogout = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: CustomColors.primaryColor,
                        title: Text("Confirm Logout", style: TextStyle(color: Colors.white),),
                        content: Text("Are you sure you want to sign out?", style: TextStyle(color: Colors.white),),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Cancel logout
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Confirm logout
                            },
                            child: Text(
                              "Logout",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldLogout == true) {
                    // Perform logout
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
                child: Text(
                    'Logout',
                    style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
                  ),
              ),
            ],
          ),
        ),
      ),
      )
      )
    );
  }
}
