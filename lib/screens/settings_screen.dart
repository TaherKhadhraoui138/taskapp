import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.coral.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withOpacity(0.15),
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
                        shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                        child: Text(
                          'Settings',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Settings list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Appearance section
                      SlideAnimation(
                        child: _buildSectionHeader('Appearance', Icons.palette_rounded, AppGradients.primary),
                      ),
                      const SizedBox(height: 16),
                      SlideAnimation(
                        delay: const Duration(milliseconds: 100),
                        child: _buildSettingCard(
                          isDark: isDark,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: themeProvider.isDarkMode
                                      ? AppGradients.aurora
                                      : AppGradients.sunset,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (themeProvider.isDarkMode
                                              ? AppColors.purple
                                              : AppColors.amber)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dark Mode', style: AppTextStyles.subtitle.copyWith(
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    )),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Use dark theme throughout the app',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: themeProvider.isDarkMode,
                                onChanged: (_) => themeProvider.toggleTheme(),
                                activeColor: AppColors.purple,
                                activeTrackColor: AppColors.purple.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      // Notifications section
                      SlideAnimation(
                        delay: const Duration(milliseconds: 150),
                        child: _buildSectionHeader('Notifications', Icons.notifications_rounded, AppGradients.secondary),
                      ),
                      const SizedBox(height: 16),
                      SlideAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: _buildSettingCard(
                          isDark: isDark,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: _notifications
                                      ? AppGradients.secondary
                                      : LinearGradient(colors: [AppColors.grey, AppColors.grey.withOpacity(0.8)]),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_notifications ? AppColors.cyan : AppColors.grey)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _notifications
                                      ? Icons.notifications_active_rounded
                                      : Icons.notifications_off_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Push Notifications', style: AppTextStyles.subtitle.copyWith(
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    )),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Receive task reminders and updates',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _notifications,
                                onChanged: (val) => setState(() => _notifications = val),
                                activeColor: AppColors.cyan,
                                activeTrackColor: AppColors.cyan.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      
                      // About section
                      SlideAnimation(
                        delay: const Duration(milliseconds: 250),
                        child: _buildSectionHeader('About', Icons.info_rounded, AppGradients.aurora),
                      ),
                      const SizedBox(height: 16),
                      SlideAnimation(
                        delay: const Duration(milliseconds: 300),
                        child: _buildSettingCard(
                          isDark: isDark,
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.info_outline_rounded,
                                title: 'About App',
                                gradient: AppGradients.aurora,
                                isDark: isDark,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                                ),
                              ),
                              Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
                              _buildMenuItem(
                                icon: Icons.lock_outline_rounded,
                                title: 'Privacy Policy',
                                gradient: AppGradients.ocean,
                                isDark: isDark,
                                onTap: () {
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
                                            child: const Icon(Icons.info_rounded, color: Colors.white, size: 16),
                                          ),
                                          const SizedBox(width: 12),
                                          Text('Privacy Policy coming soon', 
                                              style: AppTextStyles.body.copyWith(color: Colors.white)),
                                        ],
                                      ),
                                      backgroundColor: AppColors.charcoal,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // App version
                      SlideAnimation(
                        delay: const Duration(milliseconds: 350),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: AppGradients.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.coral.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.task_alt_rounded, color: Colors.white, size: 32),
                              ),
                              const SizedBox(height: 16),
                              Text('TaskAI', style: AppTextStyles.heading3.copyWith(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              )),
                              const SizedBox(height: 4),
                              Text(
                                'Version 1.0.0',
                                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
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
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.heading3),
      ],
    );
  }

  Widget _buildSettingCard({required Widget child, bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: child,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppTextStyles.subtitle.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ))),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}
