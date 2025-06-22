import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _houseController;
  late TextEditingController _districtController;
  late TextEditingController _nicknameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _usernameController =
        TextEditingController(text: userProvider.username ?? '');
    _emailController = TextEditingController(text: userProvider.email ?? '');
    _phoneController = TextEditingController(text: userProvider.phone ?? '');
    _streetController = TextEditingController(text: userProvider.street ?? '');
    _houseController = TextEditingController(text: userProvider.house ?? '');
    _districtController =
        TextEditingController(text: userProvider.district ?? '');
    _nicknameController =
        TextEditingController(text: userProvider.nickname ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _houseController.dispose();
    _districtController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateProfileHistory(
      userId: userProvider.userId!,
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      house: _houseController.text.trim(),
      district: _districtController.text.trim(),
      nickname: _nicknameController.text.trim(),
    );
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(labelText: 'Street'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter street' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _houseController,
                      decoration: const InputDecoration(labelText: 'House'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter house' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter district' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
