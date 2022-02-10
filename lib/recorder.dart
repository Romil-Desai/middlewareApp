import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Recorder extends StatefulWidget {
  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  var bytes;
  late AudioPlayer player;
  var path;
  late FlutterSoundRecorder recorder;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recorder = FlutterSoundRecorder();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void onRecord() async {
    await recorder.openRecorder();
    await recorder.startRecorder(toFile: 'foo');
    print(Codec.defaultCodec);
  }

  void onStop() async {
    path = await recorder.stopRecorder();
    final result = await http.get(Uri.parse(path!));
    bytes = result.bodyBytes;
    sendBytesToServer();
  }
 
  void onStart() async {
    player = AudioPlayer();
    player.setUrl(path);
    await player.play();
  }

  void sendBytesToServer() async {
    final response =
        await http.post(Uri.parse('http://127.0.0.1:5000/processaudio'),
            headers: {
              'Content-Type': 'application/json',
              "Access-Control-Allow-Origin":
                  "*", // Required for CORS support to work
              "Access-Control-Allow-Headers":
                  "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
              "Access-Control-Allow-Methods": "POST"
            },
            body: jsonEncode(
              <String, dynamic>{
                'audioBytes': bytes,
              },
            ));
    print(response.body);
  }

  void onStoppingPlayer() async {
    await player.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onRecord,
          child: const Text('Record'),
        ),
        TextButton(
          onPressed: onStop,
          child: const Text('Stop'),
        ),
        TextButton(
          onPressed: onStart,
          child: const Text('Start'),
        ),
        TextButton(
          onPressed: onStoppingPlayer,
          child: const Text('Stop Player'),
        ),
        TextButton(
          onPressed: sendBytesToServer,
          child: const Text('Send Bytes to server '),
        ),
      ],
    );
  }
}
