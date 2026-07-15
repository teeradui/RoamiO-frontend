import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:roamio_frontend/theme/colors.dart';
import 'package:roamio_frontend/viewmodels/notificationViewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationViewModel viewModel = NotificationViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadNotifications();
  }

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
        final int notificationCount = viewModel.notificationCount;

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Expanded(
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: viewModel.hasNotifications
                            ? viewModel.clearAll
                            : null,
                        child: Text(
                          "Clear all",
                          style: TextStyle(
                            color: viewModel.hasNotifications
                                ? AppColors.textSecondary
                                : AppColors.tabInactive,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: viewModel.hasNotifications
                                ? AppColors.textSecondary
                                : AppColors.tabInactive,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: RichText(
                      text: TextSpan(
                        text: 'You have new ',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '$notificationCount notifications',
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.tabActive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: viewModel.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : viewModel.hasNotifications
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(10, 24, 10, 0),
                            children: [
                              _NotificationGroupSection(
                                title: "Today",
                                notifications: viewModel.byGroup(
                                  NotificationGroup.today,
                                ),
                                onTap: viewModel.markAsRead,
                                onAccept: viewModel.acceptInvite,
                                onReject: viewModel.rejectInvite,
                              ),
                              _NotificationGroupSection(
                                title: "This week",
                                notifications: viewModel.byGroup(
                                  NotificationGroup.thisWeek,
                                ),
                                onTap: viewModel.markAsRead,
                                onAccept: viewModel.acceptInvite,
                                onReject: viewModel.rejectInvite,
                              ),
                              _NotificationGroupSection(
                                title: "Previous notifications",
                                notifications: viewModel.byGroup(
                                  NotificationGroup.previous,
                                ),
                                onTap: viewModel.markAsRead,
                                onAccept: viewModel.acceptInvite,
                                onReject: viewModel.rejectInvite,
                              ),
                            ],
                          )
                        : const _EmptyNotification(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyNotification extends StatelessWidget {
  const _EmptyNotification();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MingCuteIcons.mgc_message_3_ai_fill,
            size: 70,
            color: AppColors.tabInactive,
          ),
          SizedBox(height: 18),
          Text(
            "No notifications yet",
            style: TextStyle(
              color: AppColors.tabInactive,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationGroupSection extends StatelessWidget {
  const _NotificationGroupSection({
    required this.title,
    required this.notifications,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final String title;
  final List<NotificationItem> notifications;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onAccept;
  final ValueChanged<String> onReject;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.bgAccent),
            itemBuilder: (context, index) {
              final item = notifications[index];

              return _NotificationCard(
                notification: item,
                onTap: () => onTap(item.id),
                onAccept: () => onAccept(item.id),
                onReject: () => onReject(item.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  bool get isTripInvite => notification.type == NotificationType.tripInvite;
  bool get isSystem => notification.type == NotificationType.system;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.filterInactiveBg,
              child: isSystem
                  ? const Icon(
                      MingCuteIcons.mgc_message_3_ai_fill,
                      color: AppColors.filterInactiveText,
                      size: 24,
                    )
                  : Text(
                      notification.title[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    notification.timeText,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  if (isTripInvite) ...[
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(80, 34),
                            backgroundColor: AppColors.btnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text(
                            "Accept",
                            style: TextStyle(
                              color: AppColors.bgPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(80, 34),
                            side: const BorderSide(color: AppColors.btnPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                              
                            ),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(
                              color: AppColors.btnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.btnPrimary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}