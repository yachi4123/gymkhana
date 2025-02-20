import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'constants/colours.dart';
import 'widgets/video-player.dart';
import 'dart:io';

class EventDescriptionPage extends StatefulWidget {
  final String eventName;
  final String eventDescription;
  final String location;
  final DateTime dateTime;
  final String adminName;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final DateTime postedAt;

  const EventDescriptionPage({
    Key? key,
    required this.eventName,
    required this.eventDescription,
    required this.location,
    required this.dateTime,
    required this.adminName,
    required this.imageUrls,
    required this.videoUrls,
    required this.postedAt,
  }) : super(key: key);

  @override
  _EventDescriptionPageState createState() => _EventDescriptionPageState();
}

class _EventDescriptionPageState extends State<EventDescriptionPage> {
  int _currentIndex = 0;
  final Map<String, VideoPlayerController> _videoControllers = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _preloadVideos();
  }

  void _preloadVideos() async {
    for (String videoUrl in widget.videoUrls) {
      final controller = videoUrl.startsWith('http')
          ? VideoPlayerController.network(videoUrl)
          : VideoPlayerController.file(File(videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      _videoControllers[videoUrl] = controller;
    }
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Combine images and videos into one list for the carousel
    final mediaUrls = [...widget.imageUrls, ...widget.videoUrls];

    return Scaffold(
      backgroundColor: CustomColors.backgroundColor, // Match the dark theme
      appBar: AppBar(
        backgroundColor: CustomColors.backgroundColor,
        elevation: 0,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Event Name
            Text(
              widget.eventName,
              style: TextStyle(
                fontSize: 24,
                // fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Media Container (Carousel for images and videos)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomColors.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              // child: CarouselSlider(
              //   options: CarouselOptions(
              //     enlargeCenterPage: true,
              //     height: 250,
              //     autoPlay: true,
              //     // enlargeCenterPage: true,
              //     onPageChanged: (index, reason) {
              //       setState(() {
              //         _currentIndex = index;
              //       });
              //     },
              //   ),
              //   items: mediaUrls.map((mediaUrl) {
              //     if (mediaUrl.endsWith('.mp4') || mediaUrl.endsWith('.mov')) {
              //       return Builder(
              //         builder: (BuildContext context) {
              //           return VideoWidget(videoUrl: mediaUrl);
              //         },
              //       );
              //     } else {
              //       return Builder(
              //         builder: (BuildContext context) {
              //           return Container(
              //             height: 250, // Ensure it takes up the full height
              //             width: double.infinity, // Make it as wide as the container
              //             child: Image.network(
              //               mediaUrl,
              //               fit: BoxFit.cover,
              //             ),
              //           );
              //         },
              //       );
              //     }
              //   }).toList(),
              // ),
              child: CarouselSlider(
                      options: CarouselOptions(
                        enlargeCenterPage: true,
                        autoPlay: false,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1.0,
                      ),
                      items: [
                        // Display images in the carousel
                        ...widget.imageUrls.map((imageUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              if (imageUrl.startsWith('http')) {
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  child: Image.network(imageUrl, fit: BoxFit.cover)
                                );
                              } else {
                                // Load from local file path
                                return Container(
                                  height: 250,
                                  width: double.infinity,
                                  child: Image.file(File(imageUrl), fit: BoxFit.cover),
                                );
                              }
                            },
                          );
                        }).toList(),

                        // Display preloaded videos in the carousel
                        ...widget.videoUrls.map((videoUrl) {
                          final controller = _videoControllers[videoUrl];
                          return Builder(
                            builder: (BuildContext context) {
                              if (controller == null) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return Container(
                                height: 250,
                                width: double.infinity,
                                child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: VideoPlayer(controller),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      controller.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_circle_fill,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (controller.value.isPlaying) {
                                          controller.pause();
                                        } else {
                                          controller.play();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              )
                              );
                            },
                          );
                        }).toList(),
                      ],
                    )
            ),
            const SizedBox(height: 16),

            // Custom Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaUrls.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Event Description
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.eventDescription,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Location & DateTime
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.location,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('d MMM hh:mm a').format(widget.dateTime),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Posted By
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Posted By",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.black),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.adminName,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d MMM hh:mm a').format(widget.postedAt),
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
