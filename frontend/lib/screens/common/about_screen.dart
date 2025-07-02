import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
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
            // App Logo and Title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Jivhala Motors',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vehicle Management System',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            Text(
              'About Our App',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Jivhala Motors Vehicle Management System is a comprehensive solution designed to streamline vehicle inventory management for automotive businesses. Our app provides an intuitive interface for tracking vehicle details, managing customer information, and handling sales transactions efficiently.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 24),

            // Features Section
            Text(
              'Key Features',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 16),

            ..._buildFeaturesList(),

            const SizedBox(height: 24),

            // Contact Information
            Text(
              'Contact Us',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 16),

            _buildContactInfo(),

            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeaturesList() {
    final features = [
      'Complete vehicle inventory management',
      'Digital document tracking (RC, PUC, NOC)',
      'Photo documentation for vehicles',
      'Customer and buyer information management',
      'Sales tracking and reporting',
      'Vehicle status monitoring (In/Out)',
      'Search and filter capabilities',
      'Print-ready reports',
    ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildContactInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildContactRow(Icons.business, 'Jivhala Motors'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.phone, '+91 98765 43210'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.email, 'info@jivhalamotors.com'),
            const SizedBox(height: 8),
            _buildContactRow(Icons.location_on, 'Mumbai, Maharashtra, India'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
