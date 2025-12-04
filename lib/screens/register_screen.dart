import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/app_theme.dart';
import '../core/animated_widgets.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _backgroundController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = await _authService.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageTransitions.fadeScale(HomeScreen(user: user)),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Registration failed. This email may already be in use.');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_backgroundController.value * 2 * math.pi) * 0.5,
                      math.sin(_backgroundController.value * 2 * math.pi) * 0.5,
                    ),
                    end: Alignment(
                      -math.cos(_backgroundController.value * 2 * math.pi) * 0.5,
                      -math.sin(_backgroundController.value * 2 * math.pi) * 0.5,
                    ),
                    colors: isDark
                        ? [
                            AppColors.backgroundDark,
                            const Color(0xFF1A1A2E),
                          ]
                        : [
                            AppColors.backgroundLight,
                            const Color(0xFFE8EEFF),
                          ],
                  ),
                ),
              );
            },
          ),

          // Decorative circles
          Positioned(
            top: -80,
            left: -80,
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _backgroundController.value * 2 * math.pi * 0.1,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentStart.withOpacity(0.3),
                          AppColors.accentEnd.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -120,
            right: -80,
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_backgroundController.value * 2 * math.pi * 0.1,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondaryStart.withOpacity(0.2),
                          AppColors.secondaryEnd.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Back button
                          AnimatedScaleTap(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: AppShadows.small,
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.04),
                          
                          // Title
                          Center(
                            child: Column(
                              children: [
                                GradientText(
                                  text: 'Create Account',
                                  gradient: AppGradients.primary,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start your productivity journey',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: size.height * 0.05),
                          
                          // Name field
                          _buildInputLabel('Full Name'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'Enter your full name',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Email field
                          _buildInputLabel('Email Address'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Password field
                          _buildInputLabel('Password'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Create a password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondaryLight,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Register button
                          GradientButton(
                            text: 'Create Account',
                            onPressed: _register,
                            isLoading: _isLoading,
                            gradient: AppGradients.primary,
                            icon: Icons.arrow_forward_rounded,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Terms text
                          Center(
                            child: Text(
                              'By creating an account, you agree to our\nTerms of Service and Privacy Policy',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                height: 1.5,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Login link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: GradientText(
                                    text: 'Sign In',
                                    gradient: AppGradients.primary,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              prefixIcon,
              color: AppColors.primaryStart,
              size: 22,
            ),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: isDark ? AppColors.cardDark : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryStart,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.errorStart,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.errorStart,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
