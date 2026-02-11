import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/localization_extension.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.registerTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _displayNameController,
                    decoration: InputDecoration(labelText: l10n.displayName),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: l10n.email),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.password),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isBusy ? null : _register,
                    child: _isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.createAccount),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.haveAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() => _isBusy = true);
    try {
      await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Register failed');
    } catch (_) {
      _showError('Register failed');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
