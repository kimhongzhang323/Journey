import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Match app bg
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Complete'),
              Tab(text: 'Benefit'),
              Tab(text: 'Emergency'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NotificationList(type: 'Pending'),
            _NotificationList(type: 'Complete'),
            _NotificationList(type: 'Government Benefit'),
            _NotificationList(type: 'Emergency'),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final String type;

  const _NotificationList({required this.type});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final List<Map<String, dynamic>> notifications = _getMockNotifications(type);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No $type notifications', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (notif['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif['title'],
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif['message'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif['time'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (notif['hasAction'] == true)
                 Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 11)),
                 ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockNotifications(String type) {
    if (type == 'Pending') {
      return [
        {
          'title': 'MyKad Replacement Payment',
          'message': 'Payment of RM 10.00 is pending for your replacement request.',
          'time': '2 hours ago',
          'icon': Icons.payment,
          'color': Colors.orange,
          'hasAction': true,
        },
        {
          'title': 'LHDN Tax Assessment',
          'message': 'Please review your tax assessment for 2024.',
          'time': '1 day ago',
          'icon': Icons.receipt_long,
          'color': Colors.blue,
          'hasAction': true,
        },
      ];
    } else if (type == 'Complete') {
      return [
        {
          'title': 'Passport Collection',
          'message': 'Your passport is ready for collection at UTC Pudu.',
          'time': '3 days ago',
          'icon': Icons.check_circle,
          'color': Colors.green,
          'hasAction': false,
        },
        {
          'title': 'Profile Update',
          'message': 'Your phone number has been successfully updated.',
          'time': '1 week ago',
          'icon': Icons.person,
          'color': Colors.purple,
          'hasAction': false,
        },
      ];
    } else if (type == 'Government Benefit') {
      return [
        {
          'title': 'Sumbangan Tunai Rahmah (STR)',
          'message': 'Phase 1 payment of RM 500 has been credited to your account.',
          'time': 'Yesterday',
          'icon': Icons.volunteer_activism,
          'color': Colors.pink,
          'hasAction': true,
        },
        {
          'title': 'e-Madani Credit',
          'message': 'Claim your RM 100 e-wallet credit now.',
          'time': '2 days ago',
          'icon': Icons.account_balance_wallet,
          'color': Colors.teal,
          'hasAction': true,
        },
      ];
    } else if (type == 'Emergency') {
      return [
        {
          'title': 'Flood Alert',
          'message': 'Heavy rain warning in your registered area (Klang Valley).',
          'time': '1 hour ago',
          'icon': Icons.warning,
          'color': Colors.red,
          'hasAction': true,
        },
      ];
    }
    return [];
  }
}
