import 'dart:io';

import 'package:example/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zoom_allinonesdk/zoom_allinonesdk.dart';

import 'join_meeting_screen.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meetings"),
        automaticallyImplyLeading: false,
      ),
      body: _buildHeaderButtons(context),
    );
  }

  Widget _buildHeaderButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(Icons.video_camera_back, "Instant Meeting", () {
            startMeeting();
          }),
          _buildIconButton(Icons.add, "Join Meeting", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const JoinMeetingScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData iconData, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(color: Colors.white, iconData),
            ),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  void startMeeting() {
    try {
      if (kIsWeb) {
        startMeetingForWeb();
      } else if (Platform.isAndroid || Platform.isIOS) {
        startMeetingAndroidAndIOS();
      }
    } catch (e, stackTrace) {
      debugPrint('$stackTrace');
    }
  }

  void startMeetingAndroidAndIOS() async {
    ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      clientId: configs["MEETING_SDK_CLIENT_KEY"],
      clientSecert: configs["MEETING_SDK_CLIENT_SECRET"],
    );
    var meetingOptions = MeetingOptions(
        displayName: "", meetingId: "", meetingPassword: "", userType: "1");

    var zoom = ZoomAllInOneSdk();
    zoom.initZoom(zoomOptions: zoomOptions).then((results) {
      if (results[0] == 0) {
        zoom
            .startMeeting(
                accountId: configs["SERVER_TO_SERVER_ACCOUNT_ID"],
                clientId: configs["SERVER_TO_SERVER_CLIENT_KEY"],
                clientSecret: configs["SERVER_TO_SERVER_CLIENT_SECRET"],
                meetingOptions: meetingOptions)
            .then((loginResult) {
          debugPrint("loginResult $loginResult");
        });
      }
    }).catchError((error) {
      debugPrint("[Error Generated] : $error");
    });
  }

  void startMeetingForWeb() {
    ZoomOptions zoomOptions = ZoomOptions(
      domain: "zoom.us",
      clientId: configs["MEETING_SDK_CLIENT_KEY"],
      clientSecert: configs["MEETING_SDK_CLIENT_SECRET"],
      language: "en-US", // Optional - For Web
      showMeetingHeader: true, // Optional - For Web
      disableInvite: false, // Optional - For Web
      disableCallOut: false, // Optional - For Web
      disableRecord: false, // Optional - For Web
      disableJoinAudio: false, // Optional - For Web
      audioPanelAlwaysOpen: false, // Optional - For Web
    );
    var meetingOptions = MeetingOptions(
        displayName: "Web test user",
        meetingId:
            "YOUR_MEETING_ID", //Personal meeting id for start meeting required
        meetingPassword:
            "YOUR_MEETING_PASSWORD", //Personal meeting passcode for start meeting required
        userType: "1");

    var zoom = ZoomAllInOneSdk();
    zoom.initZoom(zoomOptions: zoomOptions).then((results) {
      if (results[0] == 200) {
        zoom
            .startMeeting(
                accountId: configs["SERVER_TO_SERVER_ACCOUNT_ID"],
                clientId: configs["SERVER_TO_SERVER_CLIENT_KEY"],
                clientSecret: configs["SERVER_TO_SERVER_CLIENT_SECRET"],
                meetingOptions: meetingOptions)
            .then((joinMeetingResult) {
          debugPrint("[Meeting Status Polling] : $joinMeetingResult");
        });
      }
    }).catchError((error) {
      debugPrint("[Error Generated] : $error");
    });
  }
}
