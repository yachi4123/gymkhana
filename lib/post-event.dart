import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymkhana_app/authpages/user_data.dart';
import 'package:gymkhana_app/models/event.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'constants/colours.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'profile.dart';

class PostEventPage extends StatefulWidget {
  @override
  _PostEventPageState createState() => _PostEventPageState();
}

class _PostEventPageState extends State<PostEventPage> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _location = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _mediaFiles = [];
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    HomePage(), // Your home page
    HomePage(), // Placeholder for search page
    ProfilePage(), // Current profile page
  ];

  Future<void> _pickMediaFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'mov'],
    );

    if (result != null) {
      setState(() {
        _mediaFiles =
            result.paths.where((path) => path != null).map((path) => path!).toList();
      });
    }
  }

  // Function to upload files to Supabase Storage and get signed URLs
  Future<List<String>> _uploadFilesToSupabase(List<String> filePaths) async {
  List<String> fileUrls = [];
  for (String filePath in filePaths) {
    final fileName = filePath.split('/').last;
    final fileBytes = await File(filePath).readAsBytes();

    // Upload the file to Supabase storage (with public access)
    final response = await Supabase.instance.client.storage
        .from('media-files')  // Your Supabase bucket name
        .uploadBinary('uploads/$fileName', fileBytes);

    if (response.isNotEmpty) {
      // Construct the public URL for the uploaded file
      final publicUrl = Supabase.instance.client.storage
          .from('media-files')
          .getPublicUrl('uploads/$fileName');  // Direct access to the file

      // Add the public URL to the list
      fileUrls.add(publicUrl);
    } else {
      throw Exception('Upload failed: $response');
    }
  }
  return fileUrls;
}



  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState?.save();

    // Check if date and time are selected
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {

      // Combine selected date and time into a single DateTime
      final DateTime combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Upload media files to Supabase and get signed URLs
      List<String> mediaUrls = await _uploadFilesToSupabase(_mediaFiles);
      List<String> _imageUrls = [];
      List<String> _videoUrls = [];
      for (String url in mediaUrls) {
        String extension = url.split('?').first.split('.').last;
        print(extension);
        if (extension == 'jpg' || extension == 'png') {
          _imageUrls.add(url);
        } else {
          _videoUrls.add(url);
        }
      }

      final newEvent = Event(
        title: _title,
        description: _description,
        imageUrls: _imageUrls,
        videoUrls: _videoUrls,
        postedBy: currentUsername ?? "user",
        postedAt: DateTime.now(),
        location: _location,
        dateTime: combinedDateTime,
      );
  
      // Add the event to Firestore
      await FirebaseFirestore.instance.collection('Events').add({
        'title': newEvent.title,
        'description': newEvent.description,
        'imageUrls': newEvent.imageUrls,
        'videoUrls': newEvent.videoUrls,
        'postedBy': newEvent.postedBy,
        'postedAt': newEvent.postedAt,
        'location': newEvent.location, // Include location
        'dateTime': Timestamp.fromDate(newEvent.dateTime),     // Include formatted time
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event posted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(); // Close the page after posting the event
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting event: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
}

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
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
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
      appBar: AppBar(
        backgroundColor: CustomColors.backgroundColor,
        title: const Text('Post New Event', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Title'),
              _buildTextField(
                hint: 'Enter the title of the event',
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 16),
              _buildLabel('Description'),
              _buildTextField(
                hint: 'Enter a brief description',
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),
              _buildLabel('Images & Videos'),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                color: CustomColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickMediaFiles,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: CustomColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _mediaFiles.isEmpty
                            ? const Center(
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                itemCount: _mediaFiles.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemBuilder: (context, index) {
                                  String filePath = _mediaFiles[index];
                                  if (filePath.endsWith('.jpg') ||
                                      filePath.endsWith('.png')) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(filePath),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  } else {
                                    return Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: Icon(
                                          Icons.videocam,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Location'),
              _buildTextField(
                hint: 'Enter the location',
                onSaved: (value) => _location = value ?? '',
              ),
              const SizedBox(height: 16),
              _buildLabel('Date'),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: CustomColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                        : 'Select Date',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Time'),
              GestureDetector(
                onTap: () => _pickTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: CustomColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedTime != null
                        ? "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}"
                        : 'Select Time',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Post Event',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    int maxLines = 1,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: CustomColors.primaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
      onSaved: onSaved,
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        // fontWeight: FontWeight.bold,
      ),
    );
  }
}
