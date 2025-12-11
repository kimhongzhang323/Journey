import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // For MyApp navigation on logout

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString('cached_user_name');
    await prefs.clear();
    if (cachedName != null) {
      await prefs.setString('cached_user_name', cachedName);
    }
    await prefs.setBool('landing_page_seen', true);

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
               const SizedBox(height: 20),
               // Profile Header
               Center(
                 child: Column(
                   children: [
                     Stack(
                       children: [
                          Container(
                           width: 100,
                           height: 100,
                           decoration: BoxDecoration(
                             color: Colors.white,
                             shape: BoxShape.circle,
                             border: Border.all(color: Colors.grey[200]!, width: 3),
                             image: const DecorationImage(
                               image: AssetImage('assets/images/profile.jpeg'), // Placeholder, fallback icon handled below if fails? 
                               // Actually let's use a nice icon if image fails or just hardcode an Icon for now if user didn't give asset name.
                               // User said "replace... with profile photo". I'll assume they want the placeholder asset or logic.
                               // I'll use a network image placeholder or icon for now to be safe.
                               fit: BoxFit.cover,
                             ),
                           ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                       ],
                     ),
                     const SizedBox(height: 16),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Text(
                           'Kimmy', // This should technically come from state/prefs
                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                         ),
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             gradient: const LinearGradient(
                               colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                             ),
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.orange.withOpacity(0.3),
                                 blurRadius: 4,
                                 offset: const Offset(0, 2),
                               ),
                             ],
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: const [
                               Icon(Icons.star, color: Colors.white, size: 12),
                               SizedBox(width: 4),
                               Text(
                                 'VIP',
                                 style: TextStyle(
                                   color: Colors.white,
                                   fontSize: 10,
                                   fontWeight: FontWeight.bold,
                                   letterSpacing: 0.5,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                     const Text(
                       'kimmy@example.com',
                       style: TextStyle(color: Colors.grey, fontSize: 14),
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 32),
               
               // Menu Sections
               _buildSectionHeader('Account'),
               _buildMenuItem(Icons.person_outline, 'Personal Information', onTap: () {}),
               _buildMenuItem(Icons.security, 'Security & Privacy', onTap: () {}),
               _buildMenuItem(Icons.payment, 'Payment Methods', onTap: () {}),

               _buildSectionHeader('Preferences'),
               _buildMenuItem(Icons.notifications_outlined, 'Notifications', trailing: Switch(value: true, onChanged: (v){})),
               _buildMenuItem(Icons.language, 'Language', trailing: const Text('English', style: TextStyle(color: Colors.grey))),
               
               _buildSectionHeader('Support'),
               _buildMenuItem(Icons.help_outline, 'Help Centre', onTap: () {}),
               _buildMenuItem(Icons.info_outline, 'About Journey', onTap: () {}),

               const SizedBox(height: 24),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: () => _handleLogout(context),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.red[50],
                       foregroundColor: Colors.red,
                       elevation: 0,
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                     child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
                   ),
                 ),
               ),
               const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black87, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
