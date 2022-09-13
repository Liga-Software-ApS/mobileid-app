import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';
import 'package:mobileid/application.dart';

import 'firebase_options.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseMessaging.instance.requestPermission();

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   logInfo('Got a message whilst in the foreground!');
  //   logInfo('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     logInfo('Message also contained a notification: ${message.notification}');
  //   }
  // });
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Loggy.initLoggy(
    logPrinter: const PrettyPrinter(),
  );

  configureDependencies();
  runApp(const Application());
}
