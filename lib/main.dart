import 'package:flutter/material.dart';
import 'package:roamio_frontend/screens/createTrip/create_screen.dart';
import 'package:roamio_frontend/screens/friends/friend_screen.dart';
import 'package:roamio_frontend/screens/leaderborad/leaderboard_screen.dart';
import 'package:roamio_frontend/screens/profile/profile_screen.dart';
import 'package:roamio_frontend/screens/home/home_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        canvasColor: AppColors.bgPrimary,

        
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _currentIndex = 0;
  final tabs = [
    HomeScreen(),
    LeaderboardScreen(),
    CreateTripScreen(),
    FriendScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2), // changes position of shadow
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: AppColors.tabGlow.withValues(alpha: 0.2), // สี ripple
              highlightColor: Colors.transparent, 
              splashFactory: InkRipple.splashFactory,
            ),
            child: BottomNavigationBar(
              backgroundColor: AppColors.bgPrimary,
              iconSize: 26,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedItemColor: AppColors.tabActive,
              unselectedItemColor: AppColors.tabInactive,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedHome07),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedChampion),
                  ),
                  label: 'Leaderboard',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedAddCircle),
                  ),
                  label: 'Create Trip',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedUserGroup),
                  ),
                  label: 'Friends',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedUserCircle),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
