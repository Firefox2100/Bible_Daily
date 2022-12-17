import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

import 'curvedshape.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  String _password = '';

  Future<bool?> showLoginFailedDialog(String errorContent) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error:"),
          content: Text(errorContent),
          actions: <Widget>[
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onResetPassword() async {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please input your email:"),
            content: TextField(
              decoration: const InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(color: Colors.grey)),
              controller: _emailController,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                child: const Text("Confirm"),
                onPressed: () async {
                  final nav = Navigator.of(context);
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(
                      email: _emailController.text);
                  nav.pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _onLogin() async {
    try {
      final nav = Navigator.of(context);
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _emailController.text, password: _password);
      if (credential.user != null) {
        nav.pushNamedAndRemoveUntil('home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showLoginFailedDialog('No user found for that email.');
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        showLoginFailedDialog('Wrong password provided for that user.');
        debugPrint('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        showLoginFailedDialog('The email address is badly formatted.');
        debugPrint('The email address is badly formatted.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CurvedShape(),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Login",
                  style: TextStyle(
                      color: Color.fromRGBO(49, 39, 79, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          controller: _emailController,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.grey)),
                          obscureText: true,
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: TextButton(
                    onPressed: () => _onResetPassword(),
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color.fromRGBO(196, 135, 198, 1)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: RawMaterialButton(
                    fillColor: const Color.fromRGBO(49, 39, 79, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 130,
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 50,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _onLogin(),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton(
                    child: const Text("Create Account",
                        style:
                            TextStyle(color: Color.fromRGBO(49, 39, 79, .6))),
                    onPressed: () {
                      Navigator.pushNamed(context, "register");
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
