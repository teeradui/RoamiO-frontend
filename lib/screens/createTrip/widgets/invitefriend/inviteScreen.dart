import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:roamio_frontend/screens/createTrip/widgets/invitefriend/friendCard.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/createTripViewmodel.dart';
import 'package:roamio_frontend/viewmodels/inviteFriendsViewmodel.dart';

class Step2InviteFriends extends StatefulWidget {
  const Step2InviteFriends({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<Step2InviteFriends> createState() => _Step2InviteFriendsState();
}

class _Step2InviteFriendsState extends State<Step2InviteFriends> {
  final InviteFriendsViewModel viewModel = InviteFriendsViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTrip() async {
    final createTripViewModel = context.read<CreateTripViewModel>();
 
    final tripCreated = await createTripViewModel.submitCreateTrip();
    if (!tripCreated || !mounted) return;
 
    final tripId = createTripViewModel.createdTrip?.id;
    if (tripId == null || tripId.isEmpty) return;
 
    final invitesSent = await viewModel.sendInvites(tripId);
    if (!mounted) return;
 
    // Even if some invites failed, the trip itself was created successfully.
    // We still advance — viewModel.errorMessage holds which invites failed,
    // in case the success screen wants to surface it.
    if (invitesSent || viewModel.errorMessage != null) {
      widget.onNext();
    }
  }


  @override
  Widget build(BuildContext context) {
    final createTripViewModel = context.watch<CreateTripViewModel>();
    final isBusy = createTripViewModel.isSubmitting || viewModel.isSubmitting;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Invite Friends",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "(Optional)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.btnPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add friends to join your trip.",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: viewModel.searchFriends,
                style: const TextStyle(color: AppColors.textPrimary),

                decoration: InputDecoration(
                  hintText: "Search friend by name or email",
                  hintStyle: const TextStyle(color: AppColors.tabInactive),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.tabInactive,
                  ),
                  filled: true,
                  fillColor: AppColors.bgCard,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: AppColors.bgCard),
                  ),

                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: viewModel.hasFriends
                  ? viewModel.hasFilteredFriends
                        ? ListView.builder(
                            itemCount: viewModel.filteredFriends.length,
                            itemBuilder: (context, index) {
                              final friend = viewModel.filteredFriends[index];

                              return FriendCard(
                                friend: friend,
                                isSelected: viewModel.isSelected(friend.id),
                                onTap: () {
                                  viewModel.toggleFriend(friend.id);
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "No friends found",
                              style: TextStyle(
                                color: AppColors.tabInactive,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAddTeam,
                            size: 70,
                            color: AppColors.tabInactive,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No friends added yet",
                            style: TextStyle(
                              color: AppColors.tabInactive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "${viewModel.selectedCount} ${viewModel.selectedCount == 1 ? 'member' : 'members'} will be added to the trip",
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.tabInactive,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: 180,
              height: 50,
              child: Expanded(
                child: ElevatedButton(
                  onPressed: isBusy ? null : _handleCreateTrip,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: AppColors.btnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(AppColors.bgPrimary),
                          ),
                        )
                      : const Text(
                          "Create Trip",
                          style: TextStyle(
                            color: AppColors.bgPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
 
            const SizedBox(height: 20),

          ],
        );
      },
    );
  }
}
