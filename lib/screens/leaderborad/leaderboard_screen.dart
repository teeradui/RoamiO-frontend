import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>{
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Text('Leaderboard Screen'),
    ),
  );
}
}