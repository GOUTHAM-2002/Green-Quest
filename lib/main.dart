import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:green_quest/screens/home_page.dart';
import 'package:green_quest/screens/login_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures that widget binding is initialized before any Firebase functions
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data == null) {
                    return const LoginPage();
                  } else {
                    return HomePage(
                        name: FirebaseAuth.instance.currentUser!.displayName!);
                  }
                } else {
                  return const Text("Some error occured");
                }
              }),
        ),
      ),
    );
  }
}
