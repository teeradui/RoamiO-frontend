import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_tab_selector.dart';
import 'package:roamio_frontend/screens/friends/widgets/my_friends_tab.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_request_tab.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_recommend_tab.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Friends',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              FriendTabSelector(
                selectedIndex: _selectedTab,
                onChanged: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _buildSelectedTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedTab) {
      case 0:
        return const MyFriendsTab();

      case 1:
        return const FriendRequestTab();

      case 2:
        return const FriendRecommendTab();

      default:
        return const MyFriendsTab();
    }
  }
}