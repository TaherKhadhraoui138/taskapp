import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.amber.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.coral.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: AppShadows.small,
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => AppGradients.sunset.createShader(bounds),
                        child: Text(
                          'Notifications',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      _buildActionButton(
                        icon: Icons.done_all_rounded,
                        gradient: AppGradients.secondary,
                        onTap: () async {
                          await _notificationService.markAllAsRead();
                          if (mounted) {
                            _showSnackBar('All notifications marked as read');
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildActionButton(
                        icon: Icons.delete_sweep_rounded,
                        gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade300]),
                        onTap: () => _showDeleteAllDialog(),
                      ),
                    ],
                  ),
                ),
                
                // Notifications list
                Expanded(
                  child: StreamBuilder<List<AppNotification>>(
                    stream: _notificationService.getNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppShadows.medium,
                            ),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.coral),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              Text('Error: ${snapshot.error}', style: AppTextStyles.body),
                            ],
                          ),
                        );
                      }

                      final notifications = snapshot.data ?? [];

                      if (notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PulseAnimation(
                                child: Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.amber.withOpacity(0.1),
                                        AppColors.coral.withOpacity(0.1),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => AppGradients.sunset.createShader(bounds),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      size: 56,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No notifications',
                                style: AppTextStyles.heading3.copyWith(color: AppColors.charcoal),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Notifications will appear here',
                                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return StaggeredListItem(
                            index: index,
                            child: _buildNotificationCard(notification),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Text(message, style: AppTextStyles.body.copyWith(color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.cyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeleteAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_sweep_rounded, color: Colors.red.shade400),
            ),
            const SizedBox(width: 12),
            const Text('Delete All'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete all notifications?',
          style: AppTextStyles.body.copyWith(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _notificationService.deleteAllNotifications();
      if (mounted) {
        _showSnackBar('All notifications deleted');
      }
    }
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    IconData icon;
    Gradient iconGradient;

    switch (notification.type) {
      case NotificationType.taskDeadline:
        icon = Icons.alarm_rounded;
        iconGradient = AppGradients.sunset;
        break;
      case NotificationType.taskCompleted:
        icon = Icons.check_circle_rounded;
        iconGradient = AppGradients.secondary;
        break;
      case NotificationType.taskReminder:
        icon = Icons.notifications_active_rounded;
        iconGradient = AppGradients.primary;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade300, Colors.red.shade400],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        _notificationService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted', style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppColors.cyan,
              onPressed: () {
                _notificationService.addNotification(notification);
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: notification.isRead
                ? [Colors.white, Colors.grey.shade50]
                : [Colors.white, (iconGradient as LinearGradient).colors.first.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: notification.isRead ? AppShadows.small : AppShadows.medium,
          border: notification.isRead
              ? null
              : Border.all(color: (iconGradient).colors.first.withOpacity(0.3), width: 1.5),
        ),
        child: InkWell(
          onTap: () async {
            if (!notification.isRead) {
              await _notificationService.markAsRead(notification.id);
            }

            if (notification.taskId != null) {
              _showSnackBar('Navigating to task: ${notification.taskTitle}');
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: iconGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (iconGradient).colors.first.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.subtitle.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: notification.isRead
                                    ? AppColors.grey
                                    : AppColors.charcoal,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: iconGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (iconGradient).colors.first.withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification.message,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.grey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded, size: 14, color: AppColors.grey),
                            const SizedBox(width: 6),
                            Text(
                              dateFormat.format(notification.createdAt),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

