import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:taskai/screens/settings_screen.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
import 'about_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  final Function(User)? onUserUpdated;
  
  const ProfileScreen({Key? key, required this.user, this.onUserUpdated}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local user when parent widget updates
    if (oldWidget.user != widget.user) {
      _currentUser = widget.user;
    }
  }

  void _onProfileUpdated(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
    // Also notify parent (HomeScreen) about the update
    widget.onUserUpdated?.call(updatedUser);
  }

  ImageProvider _getProfileImage(String url) {
    if (url.startsWith('data:image')) {
      // Handle base64 data URL
      final base64String = url.split(',').last;
      final bytes = base64Decode(base64String);
      return MemoryImage(Uint8List.fromList(bytes));
    } else {
      return NetworkImage(url);
    }
  }

  void _logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.coral.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.2),
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
                    AppColors.purple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Profile Avatar with glow
                  SlideAnimation(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(
                            user: _currentUser,
                            onProfileUpdated: _onProfileUpdated,
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow effect
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.coral.withOpacity(0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Avatar border
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.coral.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _getProfileImage(_currentUser.profilePictureUrl),
                            ),
                          ),
                          // Edit icon overlay
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.coral.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name
                  SlideAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: ShaderMask(
                      shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                      child: Text(
                        _currentUser.name,
                        style: AppTextStyles.heading1.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Email
                  SlideAnimation(
                    delay: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined, size: 16, color: AppColors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _currentUser.email,
                            style: AppTextStyles.body.copyWith(color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Menu items
                  SlideAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppShadows.medium,
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.edit_rounded,
                            title: 'Edit Profile',
                            gradient: AppGradients.aurora,
                            isDark: isDark,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  user: _currentUser,
                                  onProfileUpdated: _onProfileUpdated,
                                ),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 72, endIndent: 20),
                          _buildMenuItem(
                            context,
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            gradient: AppGradients.primary,
                            isDark: isDark,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            ),
                          ),
                          Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100, indent: 72, endIndent: 20),
                          _buildMenuItem(
                            context,
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            gradient: AppGradients.secondary,
                            isDark: isDark,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AboutScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Logout button
                  SlideAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () => _showLogoutDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade50,
                              Colors.red.shade100.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red.shade400, Colors.red.shade300],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Logout',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.red.shade300),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: AppTextStyles.subtitle.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              )),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
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
              child: Icon(Icons.logout_rounded, color: Colors.red.shade400),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.body.copyWith(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
