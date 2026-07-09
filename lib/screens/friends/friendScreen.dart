import 'package:flutter/material.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen>{
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Text('Friend Screen'),
    ),
  );
}
}