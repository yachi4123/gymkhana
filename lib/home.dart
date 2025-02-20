import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gymkhana_app/search.dart';
import '../models/event.dart';
import 'post-event.dart';
import '../widgets/event-card.dart';
import 'constants/colours.dart';
import 'profile.dart';
import 'authpages/user_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  User? user = FirebaseAuth.instance.currentUser;
  bool isAdmin = true;
  int _selectedIndex = 0;
  // List<Event> _allEvents = [];
  // List<Event> _filteredEvents = [];
   @override
  // void initState() {
  //   super.initState();
  //  // fetchAndStoreUserData();
  //  // _scrollToBottom();
  //  // _fetchEvents();
  //  // _scrollToBottom();
  //   _loadEvents();
  // }

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
  // Future<void> _loadEvents() async {
  //   List<Event> events = await _fetchEvents();
  //   setState(() {
  //     _allEvents = events;
  //     _filteredEvents = events; // Initially, show all events
  //   });
  // }
  Future<List<Event>> _fetchEvents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Events').orderBy('postedAt', descending: true).get();
      return querySnapshot.docs.map((doc) {
        return Event(
          title: doc['title'],
          description: doc['description'],
          imageUrls: List<String>.from(doc['imageUrls'] ?? []),
          videoUrls: List<String>.from(doc['videoUrls'] ?? []),
          postedBy: doc['postedBy'],
          postedAt: (doc['postedAt'] as Timestamp).toDate(),
          location: doc['location'],
          dateTime: (doc['dateTime'] as Timestamp).toDate(),
        );
      }).toList();
    }
    catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }
  void _scrollToBottom() {
    // Wait until the frame is drawn before scrolling
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,  // Scroll to the bottom
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }
  //@override
  // void initState() {
  //   super.initState();
  //   fetchAndStoreUserData();
  //  // _scrollToBottom();
  //  // _fetchEvents();
  //  // _scrollToBottom();
  //   _loadEvents();
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async{
        if(didPop) return;
        SystemNavigator.pop();
      },
    child: Scaffold(
      bottomNavigationBar: NavigationBar(
        backgroundColor: CustomColors.backgroundColor,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: CustomColors.secondaryColor,
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
          'IIT Indore Events',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            //color: Colors.white,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       prefixIcon: Icon(Icons.search, color: Colors.white),
          //       suffixIcon: Icon(Icons.menu, color: Colors.white),
          //       hintText: "Search",
          //       hintStyle: TextStyle(color: Colors.white70),
          //       filled: true,
          //       fillColor: CustomColors.primaryColor,
          //       border: OutlineInputBorder(
          //         borderRadius: BorderRadius.circular(12),
          //         borderSide: BorderSide.none,
          //       ),
          //     ),
          //     style: TextStyle(color: Colors.white),
          //   ),
          // ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
               stream:FirebaseFirestore.instance
                  .collection('Events')
                  .orderBy('postedAt', descending: true) // Latest events first
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No events available.', style: TextStyle(color: Colors.white)));
                }
                var events = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Event(
                    title: data['title'] ?? 'Untitled',
                    description: data['description'] ?? '',
                    imageUrls: List<String>.from(data['imageUrls'] ?? []),
                    videoUrls: List<String>.from(data['videoUrls'] ?? []),
                    postedBy: data['postedBy'] ?? 'Unknown',
                    postedAt: (data['postedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                    location: data['location'] ?? 'Unknown Location',
                    dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  );
                }).toList();
                //var events = _filteredEvents;
                return ListView.builder(
                  itemCount: events.length,
                  controller: _scrollController,
                  reverse: true, // Ensures latest event appears at the top immediately
                  itemBuilder: (context, index) {
                    return EventCard(event: events[index]);
                  },
                );
              },
            ),

            // child: FutureBuilder<List<Event>>(
            //   future: _fetchEvents(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return Center(child: Text('No events available.', style: TextStyle(color: Colors.white)));
            //     } else {
            //       return ListView.builder(
            //         itemCount: snapshot.data!.length,
            //         controller: _scrollController,
            //         //reverse: true,
            //         itemBuilder: (context, index) {
            //           return EventCard(event: snapshot.data![index]);
            //         },
            //       );
            //     }
            //   },
            // ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
            backgroundColor: CustomColors.secondaryColor,
              onPressed: () async {
                final newEvent = await Navigator.push<Event>(
                  context,
                  MaterialPageRoute(builder: (context) => PostEventPage()),
                );
                if (newEvent != null) {
                  setState(() {

                  });
                }
              },
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
      )
    );
  }
}
