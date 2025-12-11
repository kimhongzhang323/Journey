import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PerkesoPage extends StatefulWidget {
  const PerkesoPage({super.key});

  @override
  State<PerkesoPage> createState() => _PerkesoPageState();
}

class _PerkesoPageState extends State<PerkesoPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _services = [
    {
      'icon': Icons.medical_services,
      'title': 'Benefit Claims',
      'subtitle': 'Submit claims for medical benefits',
      'color': Colors.red,
    },
    {
      'icon': Icons.work,
      'title': 'MYFutureJobs',
      'subtitle': 'Search for jobs and apply',
      'color': Colors.blue,
    },
    {
      'icon': Icons.health_and_safety,
      'title': 'HSP Screening',
      'subtitle': 'Health Screening Program vouchers',
      'color': Colors.green,
    },
     {
      'icon': Icons.business,
      'title': 'Employer Registration',
      'subtitle': 'Register new employer',
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How to claim for SOCSO benefits?',
      'answer': 'Submit the relevant forms (Form 34) along with medical reports to the nearest SOCSO office.',
    },
    {
      'question': 'What is the EIS (Employment Insurance System)?',
      'answer': 'EIS provides financial assistance to workers who have lost their jobs. You can apply for Job Search Allowance (JSA).',
    },
  ];

  final List<Map<String, String>> _branches = [
    {
      'name': 'PERKESO Kuala Lumpur',
      'address': 'Wisma PERKESO, No. 155, Jalan Tun Razak, 50400 Kuala Lumpur',
      'hours': '8:00 AM - 5:00 PM'
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
            backgroundColor: Colors.cyan[700],
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
                    colors: [Colors.cyan[800]!, Colors.cyan[600]!],
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
                        const Text('PERKESO (SOCSO)', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Social Security Organization', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
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
                      Icons.phone, 'Hotline', '1-300-22-8000', Colors.cyan,
                      () => _launchUrl('tel:1300228000'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      Icons.language, 'Website', 'perkeso.gov.my', Colors.blue,
                      () => _launchUrl('https://www.perkeso.gov.my'),
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
                indicatorColor: Colors.cyan[700],
                labelColor: Colors.cyan[700],
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
              decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.help_outline, color: Colors.cyan[700], size: 20),
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
                      decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.location_on, color: Colors.cyan[700]),
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
                          foregroundColor: Colors.cyan[700],
                          side: BorderSide(color: Colors.cyan[200]!),
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
