import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/app_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'male';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showError('Please enter phone number');
      return;
    }
    setState(() => _loading = true);
    try {
      final name = _nameCtrl.text.trim();
      final password = _passwordCtrl.text.trim();
      final user = await AuthService.instance.signUp({
        'full_name': name.isNotEmpty ? name : null,
        'phone': phone,
        'password_hash': password.isNotEmpty ? password : phone, // Use phone as default password
        'role': 'patient',
        'gender': _gender,
        'age': _ageCtrl.text.trim().isNotEmpty ? int.tryParse(_ageCtrl.text.trim()) : null,
      });
      if (!mounted) return;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please sign in.')),
        );
        Navigator.of(context).pop(); // back to login
      } else {
        _showError('Failed to create account');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Create Account'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name (Optional)',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (Optional)',
                prefixIcon: Icon(Icons.lock_rounded),
                helperText: 'Defaults to phone number if empty',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender (Optional)',
                prefixIcon: Icon(Icons.wc_rounded),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageCtrl,
              decoration: const InputDecoration(
                labelText: 'Age (Optional)',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _signUp(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
