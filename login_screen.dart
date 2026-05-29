import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // For HapticFeedback

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _staggerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _formFadeAnimation;

  // Hardcoded credentials for demo/testing purposes (NOT for production!)
  static const String _validEmail = 'adityashingade01@gmail.com';
  static const String _validPassword = 'aditya2005';

  @override
  void initState() {
    super.initState();
    // Animations setup
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations with stagger
    _fadeController.forward();
    _staggerController.forward();

    // Auto-focus on User ID (rely on autofocus in TextFormField)
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();  // Slightly stronger feedback for better UX
      setState(() => _isLoading = true);
      _scaleController.forward();  // Button press animation

      // Check against hardcoded credentials (for demo only)
      if (_userIdController.text == _validEmail && _passwordController.text == _validPassword) {
        // Simulate auth delay (replace with real API call)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isLoading = false);
            _scaleController.reverse();
            // Success navigation with improved snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Login successful! Welcome back.'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pushNamed(context, '/session');
          }
        });
      } else {
        // Invalid credentials
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isLoading = false);
            _scaleController.reverse();
            // Error snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Invalid credentials. Please try again.'),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            // Clear password field for security
            _passwordController.clear();
          }
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: Color(0xFF667EEA)),
            SizedBox(width: 8),
            Text('Forgot Password?'),
          ],
        ),
        content: const Text('Contact your administrator or IT support to reset your password. We prioritize your security.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF667EEA)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return GestureDetector(  // Dismiss keyboard on tap
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // Updated gradient background for a more vibrant, modern look (purple-blue theme)
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),  // Modern blue-purple
                Color(0xFF764BA2),  // Purple accent
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),  // Bouncy scroll for better UX
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 64.0 : 24.0,  // Increased padding for tablets
                      vertical: 20.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),  // More top spacing
                          // Animated Logo with fade-in and subtle rotation - Now perfectly circular with clipping
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              final logoSize = isTablet ? 180.0 : 140.0;
                              return Opacity(
                                opacity: _fadeAnimation.value,
                                child: Transform.scale(
                                  scale: 1.0 + (_fadeAnimation.value * 0.05),
                                  child: Container(
                                    width: logoSize + 40,  // Account for padding to make container square
                                    height: logoSize + 40,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 25,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: ClipOval(  // Clip the image to a perfect circle
                                      child: Image.asset(
                                        'assets/dglogo.png',
                                        width: logoSize,
                                        height: logoSize,
                                        fit: BoxFit.cover,  // Ensure it covers the circular area without distortion
                                        semanticLabel: 'DG Ruparel College Logo',
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.school, size: 140, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Staggered title animation
                          FadeTransition(
                            opacity: _titleFadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'DG Ruparel College',
                                  style: TextStyle(
                                    fontSize: isTablet ? 32 : 26,  // Slightly larger
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                                  child: Text(
                                    'of Arts, Science and Commerce, Mumbai',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 15,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Teacher Attendance Portal',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Added welcome subtitle for better UX
                                Text(
                                  'Securely access your attendance dashboard',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isPortrait ? 80 : 60),
                          // Staggered form card with glassmorphism effect
                          FadeTransition(
                            opacity: _formFadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - _formFadeAnimation.value)),  // Slide up with stagger
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),  // Semi-transparent for glass effect
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isTablet ? 40.0 : 28.0),  // More padding
                                  child: Column(
                                    children: [
                                      // User ID Field with improved styling
                                      TextFormField(
                                        controller: _userIdController,
                                        autofocus: true,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your User ID';
                                          }
                                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value) &&
                                              !RegExp(r'^\d{5,10}$').hasMatch(value)) {
                                            return 'Enter valid User ID or email';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'User    ID / Email',
                                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF667EEA)),
                                          hintText: 'e.g., teacher@dg.edu or 12345',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2.5),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Colors.red, width: 2),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.8),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Password Field with improved styling
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: !_isPasswordVisible,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _login(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF667EEA)),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.grey[600],
                                            ),
                                            onPressed: () {
                                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                                              HapticFeedback.lightImpact();
                                            },
                                          ),
                                          hintText: 'Enter secure password',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(color: Colors.grey.shade300),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2.5),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: const BorderSide(color: Colors.red, width: 2),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.8),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Improved forgot password hint
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: _showForgotPasswordDialog,
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: const Color(0xFF667EEA),
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      // Animated Login Button with gradient
                                      ScaleTransition(
                                        scale: _scaleAnimation,
                                        child: Container(
                                          width: double.infinity,
                                          height: 60,  // Slightly taller for better touch target
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: _isLoading
                                                ? const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        height: 24,
                                                        width: 24,
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                      ),
                                                      SizedBox(width: 16),
                                                      Text(
                                                        'Signing In...',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : const Text(
                                                    'Sign In',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),
                          // Footer with improved styling
                          Opacity(
                            opacity: 0.9,
                            child: Column(
                              children: [
                                Text(
                                  'v1.1.0 | Secure Login Powered by Flutter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '© 2025 DG Ruparel College. All rights reserved.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                 
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}