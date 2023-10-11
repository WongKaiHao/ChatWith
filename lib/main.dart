import 'package:chatwith/views/search_page.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

import './views/login_page.dart';
import './views/registration_page.dart';
import './views/home_page.dart';

import './services/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatWith',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color.fromRGBO(42, 117, 188, 1),
          secondary: Color.fromRGBO(42, 117, 188, 1),
          background: Color.fromRGBO(28, 27, 27, 1)
        ),
      ),
      initialRoute: "login",
      routes: {
        "login": (BuildContext _context)=> LoginPage(),
        "register": (BuildContext _context)=> RegistrationPage(),
        "home": (BuildContext _context) => HomePage(),
        "search": (BuildContext _context) => SearchPage(),
      },
    );
  }
}