import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_notification_example/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((remoteMessage) {
    print(" --- foreground message received ---");
    print(remoteMessage.notification!.title);
    print(remoteMessage.notification!.body);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              TextField(
                  controller: _controller,
                  onChanged: (val) {
                    _controller.value = _controller.value.copyWith(
                      text: val,
                      selection: TextSelection.collapsed(offset: val.length),
                    );
                  }),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _sendMessage, child: const Text("Send it!"))
            ])));
  }

  Future _sendMessage() async {
    var token = await FirebaseMessaging.instance.getToken();
    var func = FirebaseFunctions.instance.httpsCallable("notifySubscribers");
    var res = await func.call(<String, dynamic>{
      "targetDevices": [token],
      "messageTitle": "Test title",
      "messageBody": _controller.text
    });

    print("message was ${res.data as bool ? "sent!" : "not sent!"}");
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(" --- background message received ---");
  print(message.notification!.title);
  print(message.notification!.body);
}
