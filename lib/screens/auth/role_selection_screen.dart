import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _openLogin(BuildContext context, String role) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(selectedRole: role),
      ),
    );
  }

  void _openSignup(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(selectedRole: role),
      ),
    );
  }

  void _showLoginChooser(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login As',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff0F2A44),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the role you want to log in with.',
                style: TextStyle(
                  color: Color(0xff667085),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openLogin(context, 'user'),
                  child: const Text('Login as User'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openLogin(context, 'worker'),
                  child: const Text('Login as Worker'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onTap,
    bool filled = true,
  }) {
    final Widget child = SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(label),
            ),
    );

    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffF7F9FC),
              Color(0xffE9EEF5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x190F2A44),
                      blurRadius: 28,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: 118,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'eSahayta',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff0F2A44),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '"One App..."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff667085),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _primaryButton(
                      label: 'Register as User',
                      onTap: () => _openSignup(context, 'user'),
                    ),
                    const SizedBox(height: 14),
                    _primaryButton(
                      label: 'Register as Worker',
                      onTap: () => _openSignup(context, 'worker'),
                    ),
                    const SizedBox(height: 18),
                    _primaryButton(
                      label: 'Login',
                      filled: false,
                      onTap: () => _showLoginChooser(context),
                    ),
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
