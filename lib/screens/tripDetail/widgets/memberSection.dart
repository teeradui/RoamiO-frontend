import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/memberSectionViewmodel.dart';

class MemberSection extends StatefulWidget {
  const MemberSection({super.key});

  @override
  State<MemberSection> createState() => _MemberSectionState();
}

class _MemberSectionState extends State<MemberSection> {
  final MemberSectionViewModel viewModel = MemberSectionViewModel();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.groups_rounded,
                    color: AppColors.btnPrimary,
                    size: 26,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "Trip Members (${viewModel.memberCount})",
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  if (viewModel.isCurrentUserOwner)
                    InkWell(
                      onTap: viewModel.addMember,
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.btnAdd,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          children: [
                            HugeIcon(
                             icon: HugeIcons.strokeRoundedUserAdd01,
                              size: 17,
                              color: AppColors.textAddBtn,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Add",
                              style: TextStyle(
                                color: AppColors.textAddBtn,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.bgAccent, height: 1),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: viewModel.members.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    color: AppColors.bgAccent,
                    height: 1,
                  );
                },
                itemBuilder: (context, index) {
                  final member = viewModel.members[index];

                  return _MemberTile(
                    member: member,
                    canRemove: viewModel.isCurrentUserOwner && !member.isOwner,
                    onRemove: () {
                      viewModel.removeMember(member.id);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.canRemove,
    required this.onRemove,
  });

  final TripMemberItem member;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.bgHighlight,
            backgroundImage: member.profileImageUrl != null
                ? NetworkImage(member.profileImageUrl!)
                : null,
            child: member.profileImageUrl == null
                ? Text(
                    member.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              member.username,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (member.isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: const Text(
                "Owner",
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          if (canRemove)
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                          color: AppColors.btnRemove,
                          borderRadius: BorderRadius.circular(100),
                        ),
              child: IconButton(
                onPressed: onRemove,
                icon:  HugeIcon(
                  icon: HugeIcons.strokeRoundedUserMinus01,
                  color: AppColors.textRemoveBtn,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}