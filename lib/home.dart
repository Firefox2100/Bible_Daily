import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _postController = TextEditingController();
  List<dynamic> _posts = [];
  bool _loaded = false;

  final DateTime _now = DateTime.now();
  DateTime? _start;
  DateTime? _end;

  Future<List<dynamic>> _getPosts() async {
    List<dynamic> posts = [];
    final database = FirebaseFirestore.instance;

    final result = await database
        .collection("posts")
        .where("time", isGreaterThanOrEqualTo: _start)
        .where("time", isLessThanOrEqualTo: _end)
        .get();

    for (var doc in result.docs) {
      posts.add(doc.data());
    }

    return posts;
  }

  Future<void> _onPost() async {
    final nav = Navigator.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final data = {
      'username': user!.displayName,
      'ID': user.uid,
      'post': _postController.text,
      'time': Timestamp.now()
    };

    final database = FirebaseFirestore.instance;
    await database.collection('posts').doc().set(data);

    final posts = await _getPosts();

    nav.pop();
    setState(() {
      _posts = posts;
    });
  }

  Future<void> _onCheckIn() async {
    final nav = Navigator.of(context);
    final user = FirebaseAuth.instance.currentUser;

    final data = {
      'username': user!.displayName,
      'ID': user.uid,
      'post': 'Checked in',
      'time': Timestamp.now()
    };

    final database = FirebaseFirestore.instance;
    await database.collection('posts').doc().set(data);

    final posts = await _getPosts();

    nav.pop();
    setState(() {
      _posts = posts;
    });
  }

  Future<void> _addPost() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100.0),
                    child: ElevatedButton(
                      child: const Text(
                        "Post",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _onPost(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      child: const Text(
                        "   Just\ncheck in",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _onCheckIn(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25.0, vertical: 10.0),
                child: Container(
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
                  child: TextField(
                    controller: _postController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Your daily reflex",
                      hintStyle: TextStyle(color: Colors.grey),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onEditingComplete: () => _onPost(),
                    maxLines: 10,
                    minLines: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _load() async {
    _posts = await _getPosts();

    setState(() {
      _loaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _start = DateTime(_now.year, _now.month, _now.day);
    _end = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CalendarAppBar(
        onDateChanged: (value) async {
          _start = DateTime(value.year, value.month, value.day);
          _end = DateTime(value.year, value.month, value.day, 23, 59, 59);
          final posts = await _getPosts();
          setState(() {
            _posts = posts;
          });
        },
        firstDate: DateTime.now().subtract(Duration(days: 60)),
        lastDate: DateTime.now(),
        backButton: false,
      ),
      body: Stack(
        children: [
          _loaded
              ? Scrollbar(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView.separated(
                      itemCount: _posts.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
                          color: Colors.black,
                        );
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
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
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Text(
                                      _posts[index]['username'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 15),
                                    child: Text(
                                      DateFormat('yyyy-MM-dd – kk:mm').format(
                                          _posts[index]['time'].toDate()),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                _posts[index]['post'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Container(),
          Positioned(
            right: 50,
            bottom: 70,
            child: FloatingActionButton(
              onPressed: () => _addPost(),
              backgroundColor: Colors.black,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
