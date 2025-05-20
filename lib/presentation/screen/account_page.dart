// lib/presentation/screens/account_page.dart
import 'package:flutter/material.dart';
import '../widgets/account_list_item.dart';
import 'profile_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  AccountListItem(
                    icon: Icons.person_outline,
                    title: 'Your Profile',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        ),
                  ),
                  const Divider(),
                  AccountListItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Order',
                    onTap: () {},
                  ),
                  const Divider(),
                  AccountListItem(
                    icon: Icons.credit_card,
                    title: 'Payment Methods',
                    onTap: () {},
                  ),
                  const Divider(),
                  AccountListItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  const Divider(),
                  AccountListItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(),
                  AccountListItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {},
                  ),
                  const Divider(),
                  AccountListItem(
                    icon: Icons.people_outline,
                    title: 'Invite Friends',
                    onTap: () {},
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      // Handle logout
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logging out...')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.purple),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom navigation bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home_outlined, 'Home', false),
                  _buildNavItem(Icons.favorite_border, 'Saved', false),
                  _buildNavItem(Icons.shopping_cart_outlined, 'Cart', false),
                  _buildNavItem(Icons.person_outline, 'Account', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? Colors.purple : Colors.black54),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.purple : Colors.black54,
          ),
        ),
      ],
    );
  }
}
