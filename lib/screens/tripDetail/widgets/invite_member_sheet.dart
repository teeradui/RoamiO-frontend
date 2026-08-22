import 'package:flutter/material.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/invite_friends_view_model.dart';


Future<void> showInviteMemberSheet(BuildContext context, String tripId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgPrimary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _InviteMemberSheetContent(tripId: tripId),
  );
}

class _InviteMemberSheetContent extends StatefulWidget {
  const _InviteMemberSheetContent({required this.tripId});

  final String tripId;

  @override
  State<_InviteMemberSheetContent> createState() =>
      _InviteMemberSheetContentState();
}

class _InviteMemberSheetContentState
    extends State<_InviteMemberSheetContent> {
  final InviteFriendsViewModel viewModel = InviteFriendsViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleSendInvites() async {
    await viewModel.sendInvites(widget.tripId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Invite Friends",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                onChanged: viewModel.searchFriends,
                decoration: InputDecoration(
                  hintText: "Search friend by name or email",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: viewModel.hasFilteredFriends
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: viewModel.filteredFriends.length,
                        itemBuilder: (context, index) {
                          final friend = viewModel.filteredFriends[index];
                          final isSelected = viewModel.isSelected(friend.id);

                          return ListTile(
                            title: Text(friend.username),
                            trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? AppColors.btnPrimary
                                  : AppColors.tabInactive,
                            ),
                            onTap: () => viewModel.toggleFriend(friend.id),
                          );
                        },
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            "No friends found",
                            style: TextStyle(color: AppColors.tabInactive),
                          ),
                        ),
                      ),
              ),

              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (viewModel.selectedCount > 0 && !viewModel.isSubmitting)
                      ? _handleSendInvites
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: viewModel.isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(AppColors.bgPrimary),
                          ),
                        )
                      : Text(
                          "Send Invites (${viewModel.selectedCount})",
                          style: const TextStyle(
                            color: AppColors.bgPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}