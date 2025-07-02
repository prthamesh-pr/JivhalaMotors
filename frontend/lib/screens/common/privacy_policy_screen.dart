import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildSection(
              'Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, use our vehicle management services, or contact us for support. This may include:\n\n• Personal identification information (name, username, email)\n• Vehicle information and documentation\n• Business contact details\n• Usage data and preferences',
            ),

            _buildSection(
              'How We Use Your Information',
              'We use the information we collect to:\n\n• Provide and maintain our vehicle management services\n• Process transactions and manage your account\n• Send you technical notices and support messages\n• Respond to your comments and questions\n• Improve our services and develop new features\n• Protect against fraudulent or illegal activity',
            ),

            _buildSection(
              'Information Sharing',
              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy:\n\n• With service providers who assist in our operations\n• When required by law or to protect our rights\n• In connection with a business transfer or acquisition\n• With your explicit consent',
            ),

            _buildSection(
              'Data Security',
              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
            ),

            _buildSection(
              'Data Retention',
              'We retain your information for as long as your account is active or as needed to provide services. We may retain certain information as required by law or for legitimate business purposes.',
            ),

            _buildSection(
              'Your Rights',
              'You have the right to:\n\n• Access and update your personal information\n• Delete your account and associated data\n• Opt-out of certain communications\n• Request data portability\n• Lodge complaints with supervisory authorities',
            ),

            _buildSection(
              'Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),

            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us:\n\n• Email: privacy@jivhalamotors.com\n• Phone: +91 98765 43210\n• Address: Mumbai, Maharashtra, India',
            ),

            const SizedBox(height: 32),

            Center(
              child: Text(
                '© ${DateTime.now().year} Jivhala Motors. All rights reserved.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
