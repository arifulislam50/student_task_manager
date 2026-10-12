import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _auth = AuthService();

  bool _saving = false;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = _auth.currentUser?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
      return;
    }

    setState(() => _saving = true);

    try {
      await _auth.updateName(name);

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not update name: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);

    try {
      await _auth.logout();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: const Icon(
                        Icons.person,
                        size: 54,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName?.isNotEmpty == true
                        ? user!.displayName!
                        : 'Student',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? 'No email available',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'User Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _updateName,
                      child: _saving
                          ? const CircularProgressIndicator()
                          : const Text('Update Name'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: _loggingOut ? null : _logout,
                    icon: const Icon(Icons.logout),
                    label: Text(_loggingOut ? 'Logging out...' : 'Logout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
