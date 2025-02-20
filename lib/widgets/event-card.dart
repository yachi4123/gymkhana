import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/event.dart';
import 'dart:io';
import '../constants/colours.dart';
import 'package:intl/intl.dart';
import '../event_description.dart'; // Import the EventDescriptionPage

class EventCard extends StatefulWidget {
  final Event event;
  const EventCard({required this.event});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.event.videoUrls.isNotEmpty) {
      _initializeVideo(widget.event.videoUrls.first);
    }
  }

  void _initializeVideo(String videoUrl) async {
    _videoController = videoUrl.startsWith('http')
        ? VideoPlayerController.network(videoUrl)
        : VideoPlayerController.file(File(videoUrl));

    await _videoController?.initialize();
    _videoController?.setLooping(true);
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to EventDescriptionPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDescriptionPage(
              eventName: widget.event.title,
              eventDescription: widget.event.description,
              location: widget.event.location,
              dateTime: widget.event.dateTime,
              adminName: widget.event.postedBy != "" ? widget.event.postedBy : "Some Admin",
              postedAt: widget.event.postedAt,
              imageUrls: widget.event.imageUrls,
              videoUrls: widget.event.videoUrls,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: CustomColors.primaryColor,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.event.postedBy != null
                        ? NetworkImage(widget.event.postedBy)
                        : null,
                    backgroundColor: Colors.grey,
                    radius: 24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.postedBy != "" ? widget.event.postedBy : "Some Admin",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('d MMM hh:mm a').format(widget.event.postedAt),
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              (widget.event.imageUrls.isNotEmpty || widget.event.videoUrls.isNotEmpty)
                  ? // Display event image or video
                  Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[800],
                      ),
                      child: widget.event.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.event.imageUrls.first,
                                fit: BoxFit.cover,
                              ),
                            )
                          : (_videoController != null && _videoController!.value.isInitialized)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: VideoPlayer(_videoController!),
                                )
                              : Center(
                                  child: Icon(Icons.image, size: 64, color: Colors.grey),
                                ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 16),
              Text(
                widget.event.title,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(widget.event.location, style: TextStyle(color: Colors.white)),
                  Spacer(),
                  Icon(Icons.calendar_today, color: Colors.white, size: 20),
                  SizedBox(width: 4),
                  Text(
                      DateFormat('d MMM hh:mm a').format(widget.event.dateTime),
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
