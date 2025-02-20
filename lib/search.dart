import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gymkhana_app/authpages/user_data.dart';
import 'package:gymkhana_app/widgets/event-card.dart';
import 'post-event.dart';
import '../constants/colours.dart';
import 'home.dart';
import 'authpages/login.dart';
import 'profile.dart';
import 'widgets/event-card.dart';
import 'models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}
class _SearchPageState extends State<SearchPage> {
  List<Event> _allEvents = [];
  List<Event> _filteredEvents = [];
  final TextEditingController textEditingController = TextEditingController();
  String text = "";
  int _selectedIndex = 1;

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
  Future<void> _loadEvents() async {
    List<Event> events = await _fetchEvents();
    setState(() {
      _allEvents = events;
     // _filteredEvents = events; // Initially, show all events
    });
  }
  void _filterEvents(String query) {
    text = query;
    if(text==""){
      setState(() {
        _filteredEvents = [];
      });
    }
    else
    setState(() {
      _filteredEvents = _allEvents
          .where((event) => event.title.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }
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

  @override
  void initState() {
    super.initState();
    //fetchAndStoreUserData();
   // _scrollToBottom();
   // _fetchEvents();
   // _scrollToBottom();
    _loadEvents();
  }


  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: TextField(
              controller: textEditingController,
              onChanged:_filterEvents,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white),
               // suffixIcon: Icon(Icons.menu, color: Colors.white),
                hintText: "Search by title",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: CustomColors.primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
          child:((_filteredEvents.isEmpty||_filteredEvents==null)?Center(child: Text('SEARCH....',style: TextStyle(color: Colors.white),),)
                    :ListView.builder(
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context,index){
                     // if(_filteredEvents.isNotEmpty) {
                        return EventCard(event: _filteredEvents[index]);
                     // }
                      //else{
                      //   return Container(
                      //
                      //   );
                     // }
                     // return EventCard(event: event)
                    }
                )
          )
          )
        ],
      ),
    );
  }

}