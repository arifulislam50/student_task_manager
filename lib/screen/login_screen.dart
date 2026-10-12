import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _auth.login(_email.text, _password.text);
    } catch (e) {
      if (mounted) _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Enter a valid email address first.');
      return;
    }

    try {
      await _auth.forgotPassword(email);
      if (mounted) {
        _showMessage('If the account exists, a reset email will be sent.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 76,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Student Task Manager',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stay organized. Study smarter.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password is required'
                          : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _loading ? null : _forgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            ),
                      child: const Text("Don't have an account? Sign Up"),
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
