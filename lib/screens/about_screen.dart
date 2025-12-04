import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const String _appName = 'TaskAI';
  static const String _version = '1.0.0';

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
            right: -100,
            child: Container(
              width: 300,
              height: 300,
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
            bottom: 200,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
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
          Positioned(
            top: 300,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withOpacity(0.12),
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
                          'About',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // App logo
                        SlideAnimation(
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
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.coral.withOpacity(0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // App name
                        SlideAnimation(
                          delay: const Duration(milliseconds: 100),
                          child: ShaderMask(
                            shaderCallback: (bounds) => AppGradients.primary.createShader(bounds),
                            child: Text(
                              _appName,
                              style: AppTextStyles.heading1.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Version badge
                        SlideAnimation(
                          delay: const Duration(milliseconds: 150),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppGradients.secondary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              'Version $_version',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Description card
                        SlideAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppShadows.medium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.aurora,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('What is TaskAI?', style: AppTextStyles.heading3),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'TaskAI is a Flutter mobile application for managing user tasks with the help of artificial intelligence capable of automatically classifying tasks by priority and offering smart reminders.',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.grey,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Features card
                        SlideAnimation(
                          delay: const Duration(milliseconds: 250),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppShadows.medium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.sunset,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Key Features', style: AppTextStyles.heading3),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildFeatureItem(
                                  icon: Icons.speed_rounded,
                                  title: 'Fast & Ergonomic',
                                  gradient: AppGradients.primary,
                                ),
                                _buildFeatureItem(
                                  icon: Icons.task_rounded,
                                  title: 'Efficient Task Management',
                                  gradient: AppGradients.secondary,
                                ),
                                _buildFeatureItem(
                                  icon: Icons.psychology_rounded,
                                  title: 'AI-Powered Priority Analysis',
                                  gradient: AppGradients.aurora,
                                ),
                                _buildFeatureItem(
                                  icon: Icons.cloud_sync_rounded,
                                  title: 'Firebase Cloud Sync',
                                  gradient: AppGradients.ocean,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // License button
                        SlideAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () {
                              showLicensePage(
                                context: context,
                                applicationName: _appName,
                                applicationVersion: _version,
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.coral.withOpacity(0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.description_rounded, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Text(
                                    'View Licenses',
                                    style: AppTextStyles.button.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Made with love
                        SlideAnimation(
                          delay: const Duration(milliseconds: 350),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Made with ',
                                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                              ),
                              const Icon(Icons.favorite_rounded, color: Colors.red, size: 16),
                              Text(
                                ' using Flutter',
                                style: AppTextStyles.caption.copyWith(color: AppColors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required Gradient gradient,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
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
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Icon(Icons.check_circle_rounded, color: AppColors.cyan, size: 22),
        ],
      ),
    );
  }
}
