import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../reusableWidgets/reusableFunctions.dart';
import '../reusableWidgets/reusableWidgets.dart';
import 'NavigationPage.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool invalidCredentials = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Login', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
              const SizedBox(height: 25.0,),
              ReusableTextField(labelText: 'Email', controller: emailController, isPassword: false),
              const SizedBox(height: 10.0,),
              ReusableTextField(labelText: 'Password', controller: passwordController, isPassword: true),
              const SizedBox(height: 10.0,),
              Align(
                alignment: Alignment.centerLeft,
                child: Visibility(
                  visible: invalidCredentials,
                  child: const Text('Invalid credentials. Please try again.',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
              ElevatedButton(
                onPressed: () {

                  invalidCredentials = false;
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: "devuslee1@yahoo.com",
                      password: "123123"
                  ).then((value)  {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationPage()));
                  }).onError((error, stackTrace) {
                    print("Error: $error");
                    setState(() {
                      invalidCredentials = true;
                    });
                  });
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
