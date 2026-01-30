import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import 'my_homepage.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final bool result = await _authService.signInWithGoogle();

    if (!mounted) return;

    if (result) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage(title: 'ZenMind')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In failed or cancelled'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleEmailPasswordSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool result = await _authService.signUpWithEmailPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (result) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage(title: 'ZenMind')),
      );
    } else {
      final msg = _authService.lastError ?? 'Sign Up failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  Future<void> _handleEmailPasswordSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bool result = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (result) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage(title: 'ZenMind')),
      );
    } else {
      final msg = _authService.lastError ?? 'Email/Password Sign-In failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  static const Color _bgTop = Color(0xFFF8F9F4);
  static const Color _bgBottom = Color(0xFFF0F2EA);
  static const Color _titleGreen = Color(0xFF7A8F77);
  static const Color _primaryGreen = Color(0xFF7F997B);

  static const Color _outlineBorder = Color(0xFFD6DBD1);
  static const Color _outlineFill = Color(0xFFF9FAF6);
  static const Color _textMuted = Color(0xFF7E8A7C);
  static const Color _hintMuted = Color(0xFFA8B0A4);

  Widget _pillTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      width: double.infinity,
      height: 62,
      decoration: BoxDecoration(
        color: _outlineFill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _outlineBorder, width: 1.2),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: _textMuted,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _hintMuted,
          ),
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: suffix,
                ),
          suffixIconConstraints: const BoxConstraints(
            minHeight: 40,
            minWidth: 40,
          ),
        ),
      ),
    );
  }

  Widget _primaryPillButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          color: _primaryGreen,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _secondaryPillButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          color: _outlineFill,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _outlineBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _titleGreen,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'lib/assets/leaf.png',
          height: 74,
          fit: BoxFit.contain,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'ZenMind',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: _titleGreen,
                      ),
                    ),

                    const SizedBox(height: 56),

                    _pillTextField(
                      hintText: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: 16),

                    _pillTextField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleEmailPasswordSignIn(),
                      suffix: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _textMuted,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _primaryPillButton(
                      label: 'Sign In',
                      onTap: _handleEmailPasswordSignIn,
                    ),

                    const SizedBox(height: 18),

                    _secondaryPillButton(
                      label: 'Sign Up',
                      onTap: _handleEmailPasswordSignUp,
                    ),

                    const SizedBox(height: 18),

                    GestureDetector(
                      onTap: _handleGoogleSignIn,
                      child: Container(
                        width: double.infinity,
                        height: 62,
                        decoration: BoxDecoration(
                          color: _outlineFill,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: _outlineBorder, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('lib/assets/google.webp', height: 24),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
