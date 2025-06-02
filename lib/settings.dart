// lib/settings.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ornaguide/functions/getText.dart';

class SettingsPage extends StatefulWidget {
  final FirebaseAuth auth;
  const SettingsPage({Key? key, required this.auth}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _fNameCtrl;
  late TextEditingController _lNameCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _passwordCtrl = TextEditingController();

  // Firestore reference
  final _users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    _fNameCtrl = TextEditingController();
    _lNameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = widget.auth.currentUser;
    if (user == null) return;

    final snapshot = await _users.doc(user.uid).get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    setState(() {
      _fNameCtrl.text = data['fName'] ?? '';
      _lNameCtrl.text = data['lName'] ?? '';
      _emailCtrl.text = data['email'] ?? user.email ?? '';
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = widget.auth.currentUser;
    if (user == null) return;

    try {
      // Update Firestore first and last name
      await _users.doc(user.uid).update({
        'fName': _fNameCtrl.text.trim(),
        'lName': _lNameCtrl.text.trim(),
      });

      // Update password if provided
      final newPass = _passwordCtrl.text.trim();
      if (newPass.isNotEmpty) {
        await user.updatePassword(newPass);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fNameCtrl.dispose();
    _lNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${_fNameCtrl.text} ${_lNameCtrl.text}'.trim();

    return Scaffold(
      backgroundColor: const Color(0xFF0F5451),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5451),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          getText('settings', isArabic: false),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            children: [
              // PROFILE HEADER
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white24,
                      child: Text(
                        fullName.isNotEmpty ? fullName[0] : '',
                        style: const TextStyle(fontSize: 32, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName.isNotEmpty ? fullName : 'Your Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _emailCtrl.text,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // FORM
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // First & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _fNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email (read-only, darker gray)
                        TextFormField(
                          controller: _emailCtrl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.grey[350],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // New Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(Icons.lock),
                            helperText: 'Leave blank to keep existing password',
                          ),
                          validator: (v) {
                            if (v != null && v.isNotEmpty && v.length < 6) {
                              return 'Min 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Save Button (white text)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Save Changes'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF0F5451),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _saveChanges,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // LOADING OVERLAY
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
