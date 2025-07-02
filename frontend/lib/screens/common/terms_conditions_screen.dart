import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
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
              'Terms & Conditions',
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
              'Acceptance of Terms',
              'By accessing and using the Jivhala Motors Vehicle Management System ("Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),

            _buildSection(
              'Use License',
              'Permission is granted to temporarily download one copy of Jivhala Motors app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• Modify or copy the materials\n• Use the materials for commercial purposes\n• Attempt to reverse engineer any software\n• Remove any copyright or proprietary notations',
            ),

            _buildSection(
              'Disclaimer',
              'The materials on Jivhala Motors app are provided on an "as is" basis. Jivhala Motors makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),

            _buildSection(
              'Limitations',
              'In no event shall Jivhala Motors or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Jivhala Motors app, even if Jivhala Motors or its authorized representative has been notified orally or in writing of the possibility of such damage.',
            ),

            _buildSection(
              'Accuracy of Materials',
              'The materials appearing on Jivhala Motors app could include technical, typographical, or photographic errors. Jivhala Motors does not warrant that any of the materials on its app are accurate, complete, or current. Jivhala Motors may make changes to the materials contained on its app at any time without notice.',
            ),

            _buildSection(
              'User Account',
              'When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for:\n\n• Safeguarding your password\n• All activities that occur under your account\n• Notifying us immediately of any unauthorized use\n• Maintaining the security of your account',
            ),

            _buildSection(
              'Prohibited Uses',
              'You may not use our service:\n\n• For any unlawful purpose\n• To transmit or procure sending of any advertising or promotional material\n• To impersonate or attempt to impersonate the company or employees\n• To engage in any other conduct that restricts or inhibits anyone\'s use of the service',
            ),

            _buildSection(
              'Data Protection',
              'We are committed to protecting your personal data. Our data protection practices are detailed in our Privacy Policy, which forms part of these terms and conditions.',
            ),

            _buildSection(
              'Termination',
              'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
            ),

            _buildSection(
              'Changes to Terms',
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days notice prior to any new terms taking effect.',
            ),

            _buildSection(
              'Contact Information',
              'Questions about the Terms of Service should be sent to us at:\n\n• Email: legal@jivhalamotors.com\n• Phone: +91 98765 43210\n• Address: Mumbai, Maharashtra, India',
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
