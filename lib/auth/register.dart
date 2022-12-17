import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'curvedshape.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _username = '';
  String _email = '';
  String _password = '';
  String _inviteCode = '';

  Future<bool?> showSignupFailedDialog(String errorContent) {
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

  Future<void> _onRegister() async {
    final nav = Navigator.of(context);
    final database = FirebaseFirestore.instance;
    final result = await database
        .collection("inv_codes")
        .where("ID", isEqualTo: _inviteCode)
        .get();
    if (result.size == 0) {
      showSignupFailedDialog('The invitation code does not exist.');
    } else {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        if (credential.user != null) {
          await credential.user!.updateDisplayName(_username);
          String id = credential.user!.uid;
          Map <String, dynamic> userData = {
            'ID': id,
            'IsAdmin': false
          };
          await database.collection('users').doc(id).set(userData);
          nav.pushNamedAndRemoveUntil('home', (route) => false);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          debugPrint('The password provided is too weak.');
          showSignupFailedDialog('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          debugPrint('The account already exists for that email.');
          showSignupFailedDialog('The account already exists for that email.');
        }
      } catch (e) {
        debugPrint(e.toString());
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
                  "Register",
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
                            hintText: "Username",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onChanged: (value) {
                            _username = value;
                          },
                        ),
                      ),
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
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                      ),
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
                              hintText: "Password",
                              hintStyle: TextStyle(color: Colors.grey)),
                          obscureText: true,
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Invite Code",
                              hintStyle: TextStyle(color: Colors.grey)),
                          onChanged: (value) {
                            _inviteCode = value;
                          },
                        ),
                      ),
                    ],
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
                      "Register",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _onRegister(),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton(
                    child: const Text("Have an account?",
                        style:
                            TextStyle(color: Color.fromRGBO(49, 39, 79, .6))),
                    onPressed: () {
                      Navigator.pop(context);
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
