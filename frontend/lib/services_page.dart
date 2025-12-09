import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final PageController _newsController = PageController(viewportFraction: 0.9);
  int _currentNewsIndex = 0;

  final List<Map<String, String>> _news = [
    {
      'title': 'MyKad Renewal Now Available Online',
      'subtitle': 'Skip the queue - renew your IC from home',
      'date': 'Dec 9, 2024',
    },
    {
      'title': 'Tax Filing Deadline Extended',
      'subtitle': 'LHDN extends e-Filing deadline to May 15',
      'date': 'Dec 8, 2024',
    },
    {
      'title': 'New EPF Withdrawal Scheme',
      'subtitle': 'Flexible Account 3 now open for applications',
      'date': 'Dec 7, 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good Morning', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Tan Ah Kow', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.notifications_none, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Actions
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction(Icons.qr_code_scanner, 'Scan', Colors.black),
                        _buildQuickAction(Icons.credit_card, 'MyKad', Colors.blue),
                        _buildQuickAction(Icons.flight_takeoff, 'Passport', Colors.indigo),
                        _buildQuickAction(Icons.receipt_long, 'Tax', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // News Carousel
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Latest News', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text('See all', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: PageView.builder(
                        controller: _newsController,
                        onPageChanged: (index) => setState(() => _currentNewsIndex = index),
                        itemCount: _news.length,
                        itemBuilder: (context, index) {
                          final news = _news[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(news['date']!, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                                const SizedBox(height: 8),
                                Text(news['title']!, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text(news['subtitle']!, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_news.length, (index) {
                        return Container(
                          width: _currentNewsIndex == index ? 20 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _currentNewsIndex == index ? Colors.black : Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Services Grid
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                      children: [
                        _buildServiceIcon(Icons.badge, 'JPN', Colors.blue),
                        _buildServiceIcon(Icons.flight, 'Immigration', Colors.indigo),
                        _buildServiceIcon(Icons.directions_car, 'JPJ', Colors.orange),
                        _buildServiceIcon(Icons.receipt, 'LHDN', Colors.green),
                        _buildServiceIcon(Icons.savings, 'KWSP', Colors.teal),
                        _buildServiceIcon(Icons.security, 'PERKESO', Colors.cyan),
                        _buildServiceIcon(Icons.local_hospital, 'MOH', Colors.red),
                        _buildServiceIcon(Icons.more_horiz, 'More', Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Recent Activity
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('View all', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem('MyKad Verified', 'Today, 9:30 AM', Icons.verified, Colors.green),
                    _buildActivityItem('Tax Filing Submitted', 'Dec 5, 2024', Icons.check_circle, Colors.blue),
                    _buildActivityItem('Passport Renewed', 'Nov 28, 2024', Icons.flight, Colors.indigo),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildServiceIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}
