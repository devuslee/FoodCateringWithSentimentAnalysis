import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodcateringwithsentimentanalysis/reusableWidgets/reusableColor.dart';
import 'package:foodcateringwithsentimentanalysis/screens/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foodcateringwithsentimentanalysis/screens/LoginPage.dart';
import 'package:foodcateringwithsentimentanalysis/screens/NavigationPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyC2FIvLhjPs91xQxVz15NUtam1RKHRsWIc',
      appId: '1:831398945187:android:ac435823cd0e94de9b3a16',
      messagingSenderId: '831398945187',
      projectId: 'foodcatering-6bb02',
      storageBucket: 'foodcatering-6bb02.appspot.com',
    ),
  );

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // User is signed in
    runApp(MyApp(home: NavigationPage()));
  } else {
    // User is not signed in
    runApp(MyApp(home: LoginPage()));
  }
}

class MyApp extends StatelessWidget {
  final Widget home;

  const MyApp({Key? key, required this.home}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: backGroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: home,
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
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
