import 'package:flutter/material.dart';
import 'package:barterit/models/user.dart';

// for profile screen

class ChatTabScreen extends StatefulWidget {
  final User user;

  const ChatTabScreen({super.key, required this.user});

  @override
  State<ChatTabScreen> createState() => _ChatTabScreenState();
}

class _ChatTabScreenState extends State<ChatTabScreen> {
  String maintitle = "Chat";

  @override
  void initState() {
    super.initState();
    print("Chat");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(maintitle),
      ),
      body: Text(maintitle),
    );
  }
}
