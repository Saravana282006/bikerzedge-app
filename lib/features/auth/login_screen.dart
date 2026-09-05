import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mock_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@bikerzedge.com');
  final _passwordCtrl = TextEditingController(text: 'demo1234');
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailCtrl.text,
              password: _passwordCtrl.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state.status == AuthStatus.failure &&
                      state.error != null) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(state.error!),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                  }
                },
                builder: (context, state) {
                  final busy = state.status == AuthStatus.authenticating;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _brandHeader(),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Staff sign in',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Internal access only — Admins & Mechanics.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.slate500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (v) =>
                                    (v == null || !v.contains('@'))
                                        ? 'Enter a valid email'
                                        : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Enter your password'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 50,
                                child: FilledButton(
                                  onPressed: busy ? null : _submit,
                                  child: busy
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Sign in'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _demoSection(context, busy),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandOrange,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.two_wheeler, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 16),
        const Text(
          'BIKERZEDGE',
          style: TextStyle(
            color: AppColors.brandOrange,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'MotoTrack · Workshop Job Tracker',
          style: TextStyle(
            color: AppColors.slate300,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _demoSection(BuildContext context, bool busy) {
    final mechanics = MockData.mechanics().where((m) => m.active).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.slate700)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'QUICK DEMO LOGIN',
                style: TextStyle(
                  color: AppColors.slate300,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.slate700)),
          ],
        ),
        const SizedBox(height: 14),
        _demoButton(
          context,
          label: 'Enter as Admin — ${MockData.admin.name}',
          icon: Icons.admin_panel_settings_outlined,
          onTap: busy
              ? null
              : () => context
                  .read<AuthBloc>()
                  .add(const AuthDemoLoginRequested(MockData.admin)),
        ),
        const SizedBox(height: 10),
        for (final m in mechanics) ...[
          _demoButton(
            context,
            label: 'Enter as Mechanic — ${m.name}',
            icon: Icons.engineering_outlined,
            onTap: busy
                ? null
                : () =>
                    context.read<AuthBloc>().add(AuthDemoLoginRequested(m)),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _demoButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: AppColors.brandOrangeLight),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.slate700),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
