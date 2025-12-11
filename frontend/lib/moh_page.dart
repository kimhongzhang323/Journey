import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MOHPage extends StatefulWidget {
  const MOHPage({super.key});

  @override
  State<MOHPage> createState() => _MOHPageState();
}

class _MOHPageState extends State<MOHPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.local_hospital,
      'title': 'Clinic Appointments',
      'subtitle': 'Book appointments at Klinik Kesihatan',
      'color': Colors.red,
    },
    {
      'icon': Icons.vaccines,
      'title': 'Vaccination',
      'subtitle': 'Review vaccination records (MySejahtera)',
      'color': Colors.blue,
    },
    {
      'icon': Icons.bloodtype,
      'title': 'Blood Donation',
      'subtitle': 'Find blood donation drives',
      'color': Colors.redAccent,
    },
     {
      'icon': Icons.healing,
      'title': 'Dental Services',
      'subtitle': 'Book dental checkups',
      'color': Colors.teal,
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I book an appointment?',
      'answer': 'You can use the MySejahtera app or visit the clinic website to book a slot.',
    },
    {
      'question': 'Where is the nearest Klinik Kesihatan?',
      'answer': 'Check the "Locations" tab or use Google Maps.',
    },
  ];

  final List<Map<String, String>> _branches = [
    {
      'name': 'Klinik Kesihatan Kuala Lumpur',
      'address': 'Jalan Fletcher, 53200 Kuala Lumpur',
      'hours': '8:00 AM - 5:00 PM'
    },
    {
      'name': 'Hospital Kuala Lumpur (HKL)',
      'address': 'Jalan Pahang, 50586 Kuala Lumpur',
      'hours': '24 Hours'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.red[700],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
             actions: [
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.red[800]!, Colors.red[600]!],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Government Agency', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(height: 12),
                        const Text('KKM (MOH)', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Ministry of Health Malaysia', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      Icons.phone, 'Hotline', '03-8883 3888', Colors.red,
                      () => _launchUrl('tel:0388833888'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      Icons.language, 'Website', 'moh.gov.my', Colors.blue,
                      () => _launchUrl('https://www.moh.gov.my'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.red[700],
                labelColor: Colors.red[700],
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Services'),
                  Tab(text: 'FAQ'),
                  Tab(text: 'Locations'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildServicesTab(),
                _buildFAQTab(),
                _buildLocationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
       borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                   const SizedBox(height: 2),
                   Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
     return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: (service['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(service['icon'] as IconData, color: service['color'] as Color),
            ),
            title: Text(service['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(service['subtitle'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
             trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected: ${service['title']} - Feature coming soon')));
            },
          ),
        );
      },
    );
  }

  Widget _buildFAQTab() {
     return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faqs.length,
      itemBuilder: (context, index) {
        final faq = _faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.help_outline, color: Colors.red[700], size: 20),
            ),
            title: Text(faq['question'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
             children: [
               Container(
                alignment: Alignment.centerLeft,
                 child: Text(faq['answer'] as String, style: TextStyle(color: Colors.grey[700], height: 1.5)),
               ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _branches.length,
      itemBuilder: (context, index) {
        final branch = _branches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.location_on, color: Colors.red[700]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(branch['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                           Text(branch['hours']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                   child: Row(
                    children: [
                      Icon(Icons.map, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(branch['address']!, style: TextStyle(color: Colors.grey[700], fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                 Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl('https://www.google.com/maps/search/${Uri.encodeComponent(branch['address']!)}'),
                         icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Get Directions'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          side: BorderSide(color: Colors.red[200]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(color: Colors.white, child: tabBar);
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
