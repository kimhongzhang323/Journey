import 'package:flutter/material.dart';

class FamilyChainPage extends StatefulWidget {
  const FamilyChainPage({super.key});

  @override
  State<FamilyChainPage> createState() => _FamilyChainPageState();
}

class _FamilyChainPageState extends State<FamilyChainPage> {
  // Mock Family Data
  final List<Map<String, dynamic>> _familyMembers = [
    {
      'id': 'f1',
      'name': 'Sarah Tan',
      'relation': 'Wife',
      'status': 'Active',
      'avatar': 'assets/images/profile.jpeg', // Reuse
    },
    {
      'id': 'f2',
      'name': 'Jason Tan',
      'relation': 'Son',
      'status': 'Active',
      'avatar': null, 
    },
    {
      'id': 'f3',
      'name': 'Tan Ah Beng',
      'relation': 'Father',
      'status': 'Frozen',
      'avatar': null, 
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Family Chain', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feature to add family member coming soon')));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.blue[50],
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.blue[100]!),
                 ),
                 child: Row(
                   children: [
                     Icon(Icons.security, color: Colors.blue[700], size: 32),
                     const SizedBox(width: 16),
                     const Expanded(
                       child: Text(
                         'Manage your family\'s digital safety. In emergencies, you can freeze their accounts instantly.',
                         style: TextStyle(color: Colors.blue, fontSize: 13, height: 1.4),
                       ),
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 24),
               const Text('Linked Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
               const SizedBox(height: 12),
               ..._familyMembers.map((member) => _buildMemberCard(member)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final bool isFrozen = member['status'] == 'Frozen';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: member['avatar'] != null ? AssetImage(member['avatar']) : null,
                  child: member['avatar'] == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(member['relation'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFrozen ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isFrozen ? Colors.red[100]! : Colors.green[100]!),
                  ),
                  child: Text(
                    isFrozen ? 'FROZEN' : 'ACTIVE',
                    style: TextStyle(
                      color: isFrozen ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Actions
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  label: isFrozen ? 'Unfreeze' : 'Freeze Account',
                  icon: isFrozen ? Icons.lock_open : Icons.block,
                  color: isFrozen ? Colors.green : Colors.orange,
                  onTap: () => _handleFreezeAction(member, !isFrozen),
                ),
              ),
              Container(width: 1, height: 48, color: Colors.grey[100]),
              Expanded(
                child: _buildActionBtn(
                  label: 'Emergency SOS',
                  icon: Icons.emergency,
                  color: Colors.red,
                  onTap: () => _handleSOSAction(member),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _handleSOSAction(Map<String, dynamic> member) {
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trigger Emergency SOS?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('This will alert local authorities and send ${member['name']}\'s last known location to all family members.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
               Navigator.pop(context);
               _showVerificationDialog(() {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('SOS Alert Sent! Authorities have been notified.'), backgroundColor: Colors.red),
                 );
               });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('TRIGGER SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFreezeAction(Map<String, dynamic> member, bool freeze) async {
    // 1. Initial Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(freeze ? 'Freeze ${member['name']}?' : 'Unfreeze ${member['name']}?', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(freeze 
            ? 'This will immediately lock their Digital ID and payment methods. You will need to verify your identity to proceed.' 
            : 'This will restore full access to their Digital ID and wallet.'
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: freeze ? Colors.orange : Colors.green),
            child: const Text('Proceed', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Start Multi-Factor Verification
    if (freeze) {
      _startMFAProcess(() {
         _performStatusChange(member, 'Frozen', Colors.orange);
      });
    } else {
      // Unfreeze only needs PIN or Biometric (Simplified for UX, but kept secure)
      _showVerificationDialog(() {
         _performStatusChange(member, 'Active', Colors.green);
      });
    }
  }

  void _performStatusChange(Map<String, dynamic> member, String status, Color color) {
     setState(() {
       member['status'] = status;
     });
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Account $status successfully'), backgroundColor: color),
     );
  }

  void _startMFAProcess(VoidCallback onSuccess) {
    // Step 1: Biometric
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.face, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Verifying Face ID...', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close biometric

      // Step 2: PIN
      _showVerificationDialog(() {
        // Step 3: Intent Confirmation (Text Input)
        _showIntentConfirmationDialog(onSuccess);
      });
    });
  }

  void _showIntentConfirmationDialog(VoidCallback onSuccess) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To prevent accidental freezing, please type "FREEZE" below:', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'FREEZE',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (textController.text == 'FREEZE') {
                Navigator.pop(context);
                onSuccess();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CONFIRM FREEZE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showVerificationDialog(VoidCallback onSuccess) {
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Enter Security PIN', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your 6-digit PIN to authorize this action.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 20),
                TextField(
                  controller: pinController,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                     counterText: "",
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
               TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancel')),
               ElevatedButton(
                 onPressed: () {
                   if (pinController.text.length == 6) {
                      Navigator.pop(context);
                      onSuccess();
                   } else {
                      // Shake or error
                   }
                 },
                 child: const Text('Verify'),
               ),
            ],
          );
        }
      ),
    );
  }
}
