import 'package:flutter/material.dart';

class ESignaturePage extends StatefulWidget {
  const ESignaturePage({super.key});

  @override
  State<ESignaturePage> createState() => _ESignaturePageState();
}

class _ESignaturePageState extends State<ESignaturePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Documents
  final List<Map<String, dynamic>> _documents = [
    {
      'id': 'doc001',
      'title': 'Tenancy Agreement',
      'sender': 'Speedhome Property Management',
      'date': '10 Dec 2024',
      'status': 'Pending',
      'type': 'Contract',
    },
    {
      'id': 'doc002',
      'title': 'Vehicle Hire Purchase',
      'sender': 'Public Bank Berhad',
      'date': '08 Dec 2024',
      'status': 'Pending',
      'type': 'Financial',
    },
    {
      'id': 'doc003',
      'title': 'Employment Offer Letter',
      'sender': 'Tech Solutions Sdn Bhd',
      'date': '01 Dec 2024',
      'status': 'Signed',
      'type': 'Employment',
    },
     {
      'id': 'doc004',
      'title': 'Insurance Policy Renewal',
      'sender': 'Allianz Malaysia',
      'date': '15 Nov 2024',
      'status': 'Signed',
      'type': 'Insurance',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _pendingDocs => _documents.where((d) => d['status'] == 'Pending').toList();
  List<Map<String, dynamic>> get _completedDocs => _documents.where((d) => d['status'] == 'Signed').toList();

  void _showSigningDialog(Map<String, dynamic> doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Colors.blue[50],
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Icon(Icons.description, color: Colors.blue[700]),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                         Text(doc['sender'], style: const TextStyle(color: Colors.grey)),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Preview Mock
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DOCUMENT PREVIEW', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    Container(
                      height: 400,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: Colors.grey[100],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 120, height: 16, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Container(width: double.infinity, height: 12, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Container(width: double.infinity, height: 12, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Container(width: 200, height: 12, color: Colors.grey[300]),
                          const SizedBox(height: 32),
                           Container(width: double.infinity, height: 12, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Container(width: double.infinity, height: 12, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Container(width: 150, height: 12, color: Colors.grey[300]),
                          const Spacer(),
                          // Signature placeholder
                          Container(
                            height: 80,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1), // Default solid
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text('Signature Required Here', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,-4))],
              ),
              child: SafeArea( // For bottom notch
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _verifyAndSign(doc);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052D4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.edit_document, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Sign with Digital ID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyAndSign(Map<String, dynamic> doc) {
    // Mock Authentication
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fingerprint, size: 64, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Verify Identity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Please verify your biometrics to sign this document.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Verifying...', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        setState(() {
          doc['status'] = 'Signed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document signed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('eSignature', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.black)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[700],
          tabs: [
            Tab(text: 'Pending (${_pendingDocs.length})'),
            const Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDocList(_pendingDocs, isPending: true),
          _buildDocList(_completedDocs, isPending: false),
        ],
      ),
    );
  }

  Widget _buildDocList(List<Map<String, dynamic>> docs, {required bool isPending}) {
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isPending ? Icons.check_circle_outline : Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(isPending ? 'No pending documents' : 'No history yet', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: isPending ? () => _showSigningDialog(doc) : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isPending ? Colors.blue[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPending ? Icons.assignment_late_outlined : Icons.verified_outlined,
                      color: isPending ? Colors.blue[700] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         const SizedBox(height: 4),
                         Text(doc['sender'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                         const SizedBox(height: 8),
                         Row(
                           children: [
                             Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                             const SizedBox(width: 4),
                             Text(doc['date'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                             const Spacer(),
                             if (isPending)
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                 decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                                 child: const Text('Sign Now', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                               ),
                           ],
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
