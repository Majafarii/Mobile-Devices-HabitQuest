import 'package:flutter/material.dart';

import '../models/user_account.dart';
import '../services/auth_service.dart';

/// Sign in to an existing account or create a new one.
class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.authService,
    required this.onSignedIn,
  });

  final AuthService authService;
  final ValueChanged<UserAccount> onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isSignUp = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.authService.lastUsername ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          color: colors.primary,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'HabitQuest',
                      textAlign: TextAlign.center,
                      style: textTheme.displayLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSignUp
                          ? 'Create an account to start your quests.'
                          : 'Welcome back! Sign in to continue.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _buildFields(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isBusy ? null : _toggleMode,
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign in'
                            : "Don't have an account? Sign up",
                      ),
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

  List<Widget> _buildFields(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return [
      TextFormField(
        key: const Key('auth.username'),
        controller: _usernameController,
        autocorrect: false,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
        decoration: const InputDecoration(
          labelText: 'Username',
          prefixIcon: Icon(Icons.person_outline),
        ),
        validator: (value) => _isSignUp
            ? AuthService.validateUsername(value ?? '')
            : ((value ?? '').trim().isEmpty ? 'Enter your username.' : null),
      ),
      if (_isSignUp) ...[
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('auth.displayName'),
          controller: _displayNameController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Display name (optional)',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('auth.email'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email (optional)',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            final email = (value ?? '').trim();
            if (email.isEmpty) return null;
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                ? null
                : 'Enter a valid email address.';
          },
        ),
      ],
      const SizedBox(height: 12),
      TextFormField(
        key: const Key('auth.password'),
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: _isSignUp
            ? TextInputAction.next
            : TextInputAction.done,
        autofillHints: [
          _isSignUp ? AutofillHints.newPassword : AutofillHints.password,
        ],
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        validator: (value) => _isSignUp
            ? AuthService.validatePassword(value ?? '')
            : ((value ?? '').isEmpty ? 'Enter your password.' : null),
        onFieldSubmitted: (_) {
          if (!_isSignUp) _submit();
        },
      ),
      if (_isSignUp) ...[
        const SizedBox(height: 12),
        TextFormField(
          key: const Key('auth.confirmPassword'),
          controller: _confirmController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: Icon(Icons.lock_reset_outlined),
          ),
          validator: (value) => value == _passwordController.text
              ? null
              : 'Passwords do not match.',
          onFieldSubmitted: (_) => _submit(),
        ),
      ],
      const SizedBox(height: 4),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('Keep me signed in'),
        value: _rememberMe,
        onChanged: (value) => setState(() => _rememberMe = value ?? true),
      ),
      if (_error != null) ...[
        Text(
          _error!,
          style: TextStyle(color: colors.error),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
      FilledButton(
        key: const Key('auth.submit'),
        onPressed: _isBusy ? null : _submit,
        child: _isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(_isSignUp ? 'Create account' : 'Sign in'),
      ),
    ];
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _error = null;
      _passwordController.clear();
      _confirmController.clear();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final account = _isSignUp
          ? await widget.authService.signUp(
              username: _usernameController.text,
              displayName: _displayNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              rememberMe: _rememberMe,
            )
          : await widget.authService.signIn(
              username: _usernameController.text,
              password: _passwordController.text,
              rememberMe: _rememberMe,
            );
      if (!mounted) return;
      widget.onSignedIn(account);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
        _isBusy = false;
      });
    }
  }
}
