import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart'; // Import the EditProfileScreen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: user == null
          ? _buildNotLoggedIn()
          : _buildUserProfileWithFirestore(context, user),
    );
  }

  Widget _buildNotLoggedIn() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Not Logged In',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileWithFirestore(BuildContext context, User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // If no Firestore data, show basic auth data
          return _buildUserProfile(context, user, null);
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return _buildUserProfile(context, user, userData);
      },
    );
  }

  Widget _buildUserProfile(BuildContext context, User user, Map<String, dynamic>? userData) {
    // Use Firestore data if available, otherwise use Auth data
    final displayName = userData?['displayName'] ?? user.displayName ?? 'No Name';
    final email = userData?['email'] ?? user.email ?? 'No Email';
    final createdAt = userData?['createdAt'] != null
        ? (userData?['createdAt'] as Timestamp).toDate().toString()
        : (user.metadata.creationTime != null
        ? user.metadata.creationTime!.toLocal().toString()
        : 'Unknown');

    return SingleChildScrollView( // ADDED: Wrap with SingleChildScrollView
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header - Centered like the design
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // ADDED: Center text
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center, // ADDED: Center text
                ),
                const SizedBox(height: 8),
                Chip(
                  backgroundColor: user.emailVerified
                      ? Colors.green[100]
                      : Colors.orange[100],
                  label: Text(
                    user.emailVerified ? 'Verified' : 'Not Verified',
                    style: TextStyle(
                      color: user.emailVerified
                          ? Colors.green[800]
                          : Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Divider line
          const Divider(thickness: 1),

          const SizedBox(height: 24),

          // Account Details Section
          const Text(
            'Account Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Details in simple list format without cards
          _buildDetailItem(
            title: 'Display Name',
            value: displayName,
          ),
          _buildDetailItem(
            title: 'Email',
            value: email,
          ),
          _buildDetailItem(
            title: 'Email Verified',
            value: user.emailVerified ? 'Yes' : 'No',
          ),
          _buildDetailItem(
            title: 'Account Created',
            value: _formatCreationTime(createdAt),
          ),

          const SizedBox(height: 32),

          // Actions - FIXED: Added margin at bottom for safe area
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile screen
                  _navigateToEditProfile(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16), // ADDED: Extra bottom padding
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
      ),
    );
  }

  String _formatCreationTime(String createdAt) {
    try {
      // Format the date to be more readable
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt; // Return original if parsing fails
    }
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    ).then((value) {
      // Optional: Refresh data if needed when returning from edit screen
      if (value == true) {
        // The StreamBuilder will automatically update due to the stream
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _logout(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    // Try using Provider first, fallback to direct FirebaseAuth
    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      authProvider.signOut();
    } catch (e) {
      // Fallback: Sign out directly using FirebaseAuth
      FirebaseAuth.instance.signOut();
    }

    // Navigate to login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }
}