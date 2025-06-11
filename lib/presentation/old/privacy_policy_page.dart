// lib/presentation/screen/privacy_policy_page.dart
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: June 15, 2023',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Introduction'),
            _buildParagraph(
              'Welcome to our E-Commerce App. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            _buildParagraph(
              'Please read this Privacy Policy carefully. By accessing or using our application, you acknowledge that you have read, understood, and agree to be bound by all the terms outlined in this Privacy Policy.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('2. Information We Collect'),
            _buildSubsectionTitle('2.1 Personal Information'),
            _buildParagraph(
              'We may collect personal information that you voluntarily provide to us when you register for an account, express interest in obtaining information about us or our products, or otherwise contact us. The personal information we collect may include:',
            ),
            _buildBulletPoint('Name'),
            _buildBulletPoint('Email address'),
            _buildBulletPoint('Phone number'),
            _buildBulletPoint('Billing and shipping address'),
            _buildBulletPoint('Payment information'),
            _buildBulletPoint('Date of birth'),
            _buildSubsectionTitle('2.2 Automatically Collected Information'),
            _buildParagraph(
              'When you use our application, we automatically collect certain information about your device, including:',
            ),
            _buildBulletPoint('Device type and operating system'),
            _buildBulletPoint('IP address'),
            _buildBulletPoint('Browser type'),
            _buildBulletPoint('Geographic location'),
            _buildBulletPoint('Time spent on the application'),
            _buildBulletPoint('Pages viewed'),
            const SizedBox(height: 16),
            _buildSectionTitle('3. How We Use Your Information'),
            _buildParagraph(
              'We may use the information we collect for various purposes, including:',
            ),
            _buildBulletPoint('To provide and maintain our services'),
            _buildBulletPoint('To process and complete transactions'),
            _buildBulletPoint('To send you order confirmations and updates'),
            _buildBulletPoint('To provide customer support'),
            _buildBulletPoint('To personalize your experience'),
            _buildBulletPoint('To send promotional'),
            // lib/presentation/screen/privacy_policy_page.dart (continued)
            _buildBulletPoint('To send promotional emails and updates'),
            _buildBulletPoint('To improve our application and services'),
            _buildBulletPoint(
              'To protect against fraud and unauthorized transactions',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('4. Sharing Your Information'),
            _buildParagraph(
              'We may share your information with third parties in certain situations, including:',
            ),
            _buildBulletPoint(
              'With service providers who perform services for us',
            ),
            _buildBulletPoint('To comply with legal obligations'),
            _buildBulletPoint('To protect and defend our rights and property'),
            _buildBulletPoint('With your consent or at your direction'),
            const SizedBox(height: 16),
            _buildSectionTitle('5. Data Security'),
            _buildParagraph(
              'We use administrative, technical, and physical security measures to protect your personal information. While we have taken reasonable steps to secure the personal information you provide to us, please be aware that no security measures are perfect or impenetrable, and we cannot guarantee the security of your personal information.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('6. Your Privacy Rights'),
            _buildParagraph(
              'Depending on your location, you may have certain rights regarding your personal information, such as:',
            ),
            _buildBulletPoint('Right to access your personal information'),
            _buildBulletPoint('Right to correct inaccurate information'),
            _buildBulletPoint('Right to request deletion of your information'),
            _buildBulletPoint('Right to restrict or object to processing'),
            _buildBulletPoint('Right to data portability'),
            _buildParagraph(
              'To exercise these rights, please contact us using the information provided in the "Contact Us" section below.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('7. Changes to This Privacy Policy'),
            _buildParagraph(
              'We may update this Privacy Policy from time to time. The updated version will be indicated by an updated "Last Updated" date and the updated version will be effective as soon as it is accessible. We encourage you to review this Privacy Policy frequently to be informed of how we are protecting your information.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('8. Contact Us'),
            _buildParagraph(
              'If you have questions or comments about this Privacy Policy, please contact us at:',
            ),
            _buildParagraph(
              'E-Commerce App\nsupport@ecommerceapp.com\n123 Main Street, City, Country',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5)),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
