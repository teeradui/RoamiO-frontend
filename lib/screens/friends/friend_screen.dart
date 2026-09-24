import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/friends/friend_profile_screen.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_tab_selector.dart';
import 'package:roamio_frontend/screens/friends/widgets/my_friends_tab.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_request_tab.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_recommend_tab.dart';
import 'package:roamio_frontend/screens/friends/widgets/friend_card.dart';
import 'package:roamio_frontend/viewmodels/friend_request_view_model.dart';
import 'package:roamio_frontend/viewmodels/friend_search_view_model.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendSearchViewModel()),
        ChangeNotifierProvider(
          create: (_) => FriendRequestViewModel()..loadRequests(),
        ),
      ],
      child: const _FriendScreenView(),
    );
  }
}

class _FriendScreenView extends StatefulWidget {
  const _FriendScreenView();

  @override
  State<_FriendScreenView> createState() => _FriendScreenViewState();
}

class _FriendScreenViewState extends State<_FriendScreenView> {
  int _selectedTab = 0;

  Widget _buildFriendRequestAction(
    BuildContext context,
    FriendSearchViewModel viewModel,
    FriendItem user,
  ) {
    final status = viewModel.getRequestStatus(user.userId);
    final errorMessage = viewModel.getRequestError(user.userId);

    if (status == FriendRequestStatus.friends) {
      return const Text(
        'Friends',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (status == FriendRequestStatus.pending) {
      return const Text(
        'Pending',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return IconButton(
      onPressed: () async {
        await viewModel.sendFriendRequest(user.userId);

        final error = viewModel.getRequestError(user.userId);

        if (context.mounted && error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      },
      icon: const Icon(
        MingCuteIcons.mgc_user_add_2_line,
        color: AppColors.btnPrimary,
        size: 24,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<FriendSearchViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: viewModel.searchUsers,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search by name or username',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: const Icon(
                MingCuteIcons.mgc_search_line,
                color: AppColors.textSecondary,
                size: 22,
              ),
              suffixIcon: viewModel.isSearching
                  ? IconButton(
                      onPressed: () {
                        viewModel.clearSearch();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(FriendSearchViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    if (viewModel.searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No users found.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: viewModel.searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = viewModel.searchResults[index];

        return FriendCard(
          friend: user,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendProfileScreen(userId: user.userId),
              ),
            );
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFriendRequestAction(context, viewModel, user),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Friends',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Your Adventure Crew!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              _buildSearchBar(),

              const SizedBox(height: 20),

              Consumer<FriendSearchViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isSearching) {
                    return const SizedBox.shrink();
                  }

                  return Consumer<FriendRequestViewModel>(
                    builder: (context, requestViewModel, _) {
                      return FriendTabSelector(
                        selectedIndex: _selectedTab,
                        requestCount: requestViewModel.requests.length,
                        onChanged: (index) {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Consumer<FriendSearchViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isSearching) {
                      return _buildSearchResults(viewModel);
                    }

                    return _buildSelectedTab();
                  },
                ),
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
