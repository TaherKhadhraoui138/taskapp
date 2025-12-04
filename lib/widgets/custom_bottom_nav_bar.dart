import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../core/app_theme.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.calendar_today_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  final List<IconData> _selectedIcons = [
    Icons.home_filled,
    Icons.bar_chart_rounded,
    Icons.calendar_today_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    'Home',
    'Stats',
    'Calendar',
    'Alerts',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animations = List.generate(5, (index) {
      return Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.cardDark.withOpacity(0.9)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryStart.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final isSelected = widget.selectedIndex == index;
                
                return GestureDetector(
                  onTap: () => widget.onItemTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: isSelected ? 1.0 : 0.8),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 16 : 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppGradients.primary : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryStart.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon with notification badge for index 3
                          index == 3
                              ? StreamBuilder<int>(
                                  stream: notificationService.getUnreadCount(),
                                  builder: (context, snapshot) {
                                    final unreadCount = snapshot.data ?? 0;
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Icon(
                                          isSelected ? _selectedIcons[index] : _icons[index],
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                          size: 24,
                                        ),
                                        if (unreadCount > 0)
                                          Positioned(
                                            right: -8,
                                            top: -8,
                                            child: TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0.0, end: 1.0),
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.elasticOut,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: child,
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                constraints: const BoxConstraints(
                                                  minWidth: 18,
                                                  minHeight: 18,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: AppGradients.error,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isDark ? AppColors.cardDark : Colors.white,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.errorStart.withOpacity(0.3),
                                                      blurRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                )
                              : Icon(
                                  isSelected ? _selectedIcons[index] : _icons[index],
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  size: 24,
                                ),
                          
                          // Label (only for selected)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: isSelected
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      _labels[index],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
