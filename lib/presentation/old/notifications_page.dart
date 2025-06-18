// lib/presentation/screen/notifications_page.dart
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Your order has been shipped!',
      'description': 'Order #ORD-0012 has been shipped and is on its way.',
      'time': '2 hours ago',
      'isRead': false,
      'type': 'order',
    },
    {
      'title': 'Special Offer!',
      'description': 'Get 20% off on all summer collection items.',
      'time': '1 day ago',
      'isRead': true,
      'type': 'promo',
    },
    {
      'title': 'Payment Successful',
      'description':
          'Your payment of RM154.00 for order #ORD-0012 was successful.',
      'time': '2 days ago',
      'isRead': true,
      'type': 'payment',
    },
    {
      'title': 'New Collection Arrived',
      'description': 'Check out our latest collection of premium products.',
      'time': '1 week ago',
      'isRead': true,
      'type': 'promo',
    },
  ];

  bool _allNotifications = true;
  bool _orderUpdates = false;
  bool _promotions = true;
  bool _paymentUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              _showNotificationSettings();
            },
          ),
        ],
      ),
      body:
          _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: notification['isRead'] ? 1 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color:
                        notification['isRead'] ? Colors.white : Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildNotificationIcon(notification['type']),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification['title'],
                                        style: TextStyle(
                                          fontWeight:
                                              notification['isRead']
                                                  ? FontWeight.w500
                                                  : FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      notification['time'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notification['description'],
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!notification['isRead'])
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        notification['isRead'] = true;
                                      });
                                    },
                                    child: Text(
                                      'Mark as read',
                                      style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            for (var notification in _notifications) {
              notification['isRead'] = true;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All notifications marked as read')),
          );
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.done_all),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (type) {
      case 'order':
        iconData = Icons.local_shipping_outlined;
        backgroundColor = Colors.orange[100]!;
        iconColor = Colors.orange[800]!;
        break;
      case 'promo':
        iconData = Icons.discount_outlined;
        backgroundColor = Colors.purple[100]!;
        iconColor = Colors.purple[800]!;
        break;
      case 'payment':
        iconData = Icons.payment_outlined;
        backgroundColor = Colors.green[100]!;
        iconColor = Colors.green[800]!;
        break;
      default:
        iconData = Icons.notifications_outlined;
        backgroundColor = Colors.blue[100]!;
        iconColor = Colors.blue[800]!;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSetting(
                    'All Notifications',
                    _allNotifications,
                    (value) {
                      setState(() {
                        _allNotifications = value;
                        if (_allNotifications) {
                          _orderUpdates = true;
                          _promotions = true;
                          _paymentUpdates = true;
                        } else {
                          _orderUpdates = false;
                          _promotions = false;
                          _paymentUpdates = false;
                        }
                      });
                    },
                  ),
                  const Divider(),
                  _buildNotificationSetting('Order Updates', _orderUpdates, (
                    value,
                  ) {
                    setState(() {
                      _orderUpdates = value;
                      _updateAllNotificationsState();
                    });
                  }),
                  const Divider(),
                  _buildNotificationSetting(
                    'Promotions & Offers',
                    _promotions,
                    (value) {
                      setState(() {
                        _promotions = value;
                        _updateAllNotificationsState();
                      });
                    },
                  ),
                  const Divider(),
                  _buildNotificationSetting(
                    'Payment Updates',
                    _paymentUpdates,
                    (value) {
                      setState(() {
                        _paymentUpdates = value;
                        _updateAllNotificationsState();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification settings saved'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationSetting(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.purple),
      ],
    );
  }

  void _updateAllNotificationsState() {
    if (_orderUpdates && _promotions && _paymentUpdates) {
      _allNotifications = true;
    } else {
      _allNotifications = false;
    }
  }
}
