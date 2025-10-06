import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPasswordFields = false;
  bool _emailSent = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (_user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _displayNameController.text = userData['displayName'] ?? _user!.displayName ?? '';
        });
      } else {
        setState(() {
          _displayNameController.text = _user!.displayName ?? '';
        });
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_displayNameController.text.isNotEmpty &&
          _displayNameController.text != _user!.displayName) {
        await _user!.updateDisplayName(_displayNameController.text);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({
          'displayName': _displayNameController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('Update Failed', e.message ?? 'An error occurred');
    } catch (e) {
      _showErrorDialog('Update Failed', 'An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (!_validatePasswordForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: _currentPasswordController.text,
      );

      await _user!.reauthenticateWithCredential(credential);
      await _user!.updatePassword(_newPasswordController.text);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _showPasswordFields = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        _showErrorDialog('Change Password Failed', 'Current password is incorrect');
      } else if (e.code == 'weak-password') {
        _showErrorDialog('Change Password Failed', 'Password is too weak. Use at least 6 characters.');
      } else {
        _showErrorDialog('Change Password Failed', e.message ?? 'An error occurred');
      }
    } catch (e) {
      _showErrorDialog('Change Password Failed', 'An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validatePasswordForm() {
    if (_currentPasswordController.text.isEmpty) {
      _showErrorDialog('Validation Error', 'Please enter your current password');
      return false;
    }

    if (_newPasswordController.text.length < 6) {
      _showErrorDialog('Validation Error', 'New password must be at least 6 characters long');
      return false;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Validation Error', 'New passwords do not match');
      return false;
    }

    if (_currentPasswordController.text == _newPasswordController.text) {
      _showErrorDialog('Validation Error', 'New password must be different from current password');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _sendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _user!.sendEmailVerification();

      if (mounted) {
        setState(() {
          _emailSent = true;
        });
        _showEmailTroubleshootingDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
            'Verification Failed',
            'Failed to send verification email. Please try again later.\n\nError: ${e.toString()}'
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEmailTroubleshootingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.troubleshoot, color: Colors.orange),
            SizedBox(width: 8),
            Text('Email Troubleshooting'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Firebase confirmed the email was sent, but if you\'re not receiving it:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              _buildTroubleshootingStep(
                '1. Check Spam/Junk Folder',
                'Gmail often filters Firebase emails as spam',
              ),

              _buildTroubleshootingStep(
                '2. Check "All Mail" and "Promotions"',
                'Look in all Gmail categories',
              ),

              _buildTroubleshootingStep(
                '3. Search for "Firebase"',
                'Search your entire Gmail account',
              ),

              _buildTroubleshootingStep(
                '4. Wait 10-15 minutes',
                'Email delivery can be delayed',
              ),

              _buildTroubleshootingStep(
                '5. Try a different email provider',
                'Use Outlook, Yahoo, or iCloud instead of Gmail',
              ),

              _buildTroubleshootingStep(
                '6. Check Firebase Console',
                'Ensure your project is properly configured',
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Technical Details:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('From: no-reply@firebaseapp.com'),
                    Text('To: ${_user!.email}'),
                    Text('Subject: Verify your email'),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Common issue: Firebase emails are often blocked or filtered by Gmail.',
                style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _user!.reload();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sendVerificationEmail();
            },
            child: const Text('Resend'),
          ),
          TextButton(
            onPressed: _openGmail,
            child: const Text('Open Gmail'),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _openGmail() async {
    const gmailUrl = 'https://mail.google.com';
    try {
      // You might want to use url_launcher package for this
      // await launchUrl(Uri.parse(gmailUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please open Gmail manually and check spam folder'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check Gmail in your browser'),
        ),
      );
    }
  }

  // Add this method to test with a different email
  void _testWithDifferentEmail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test with Different Email'),
        content: const Text(
          'The issue might be specific to Gmail. Try creating a new account with:'
              '\n\n• Outlook.com\n• Yahoo.com\n• iCloud.com\n• Any other email provider',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _user == null
          ? const Center(child: Text('User not found'))
          : _buildEditForm(),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProfilePictureSection(),
            const SizedBox(height: 24),
            _buildDisplayNameSection(),
            const SizedBox(height: 24),
            if (!_user!.emailVerified) _buildEmailVerificationSection(),
            const SizedBox(height: 24),
            _buildPasswordSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),

            // Add troubleshooting section
            const SizedBox(height: 20),
            _buildTroubleshootingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingSection() {
    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Still not receiving emails?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a common issue with Firebase and Gmail. Try these solutions:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _testWithDifferentEmail,
                child: const Text('Try Different Email Provider'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a new account with Outlook, Yahoo, or iCloud instead of Gmail.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.grey[600],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture upload coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Change Profile Picture'),
        ),
      ],
    );
  }

  Widget _buildDisplayNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _displayNameController,
          decoration: const InputDecoration(
            hintText: 'Enter your display name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a display name';
            }
            if (value.trim().length < 2) {
              return 'Display name must be at least 2 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailVerificationSection() {
    return Card(
      color: _emailSent ? Colors.blue[50] : Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _emailSent ? Icons.email : Icons.warning_amber,
                  color: _emailSent ? Colors.blue[800] : Colors.orange[800],
                ),
                const SizedBox(width: 8),
                Text(
                  _emailSent ? 'Verification Email Sent' : 'Email Not Verified',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _emailSent ? Colors.blue[800] : Colors.orange[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _emailSent
                  ? 'Check your email (including spam) for the verification link.'
                  : 'Verify your email to access all features. Gmail users: check spam folder.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _sendVerificationEmail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _emailSent ? Colors.blue[800] : Colors.orange[800],
                  side: BorderSide(
                    color: _emailSent ? Colors.blue[800]! : Colors.orange[800]!,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _emailSent ? Icons.refresh : Icons.email,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(_emailSent ? 'Resend Verification' : 'Send Verification Email'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _showPasswordFields = !_showPasswordFields;
                      if (!_showPasswordFields) {
                        _currentPasswordController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      }
                    });
                  },
                  icon: Icon(
                    _showPasswordFields ? Icons.expand_less : Icons.expand_more,
                  ),
                ),
              ],
            ),

            if (_showPasswordFields) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                  hintText: 'At least 6 characters',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.verified_user),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_reset, size: 18),
                      SizedBox(width: 8),
                      Text('Change Password'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: 18),
                SizedBox(width: 8),
                Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}