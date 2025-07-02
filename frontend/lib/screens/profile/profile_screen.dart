import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../routes.dart';
import '../../widgets/common_widgets.dart';
import '../../config/theme.dart';
import '../../utils/animations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return CommonWidgets.emptyStateWidget(
              message: 'User information not available',
              icon: Icons.person_off,
            );
          }

          return CustomScrollView(
            slivers: [
              // Enhanced App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // Enhanced Profile Avatar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Stats Cards
                        _buildQuickStatsSection(context),

                        const SizedBox(height: 32),

                        // Menu Items
                        _buildMenuSection(context, 'Account', [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.edit_outlined,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            onTap: () =>
                                AppRoutes.push(context, AppRoutes.editProfile),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            subtitle: 'Update your password',
                            onTap: () => AppRoutes.push(
                              context,
                              AppRoutes.changePassword,
                            ),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildMenuSection(context, 'Preferences', [
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return _buildThemeMenuItem(themeProvider);
                            },
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildMenuSection(context, 'Data Export', [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.file_download_outlined,
                            title: 'Export Vehicle Data',
                            subtitle: 'Download vehicle list as PDF',
                            onTap: () => _exportVehicleData(context),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildMenuSection(context, 'Support', [
                          _buildMenuItem(
                            context: context,
                            icon: Icons.info_outline,
                            title: 'About Us',
                            subtitle: 'Learn more about Jivhala Motors',
                            onTap: () =>
                                AppRoutes.push(context, AppRoutes.about),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            subtitle: 'Read our privacy policy',
                            onTap: () => AppRoutes.push(
                              context,
                              AppRoutes.privacyPolicy,
                            ),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.description_outlined,
                            title: 'Terms & Conditions',
                            subtitle: 'Read our terms and conditions',
                            onTap: () => AppRoutes.push(
                              context,
                              AppRoutes.termsConditions,
                            ),
                          ),
                        ]),

                        const SizedBox(height: 32),

                        // Enhanced Logout Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.error,
                                colorScheme.error.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.error.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () =>
                                _showLogoutDialog(context, authProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStatsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final vehicles = vehicleProvider.vehicles;
        final totalVehicles = vehicles.length;
        final vehiclesIn = vehicles
            .where((v) => v.status.toLowerCase() == 'in')
            .length;
        final vehiclesOut = vehicles
            .where((v) => v.status.toLowerCase() == 'out')
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppAnimations.fadeIn(
              Text(
                'Quick Overview',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              duration: const Duration(milliseconds: 600),
            ),
            const SizedBox(height: 16),
            AppAnimations.slideFromBottom(
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: AppAnimations.scaleIn(
                          _buildStatCard(
                            context,
                            'Total\nVehicles',
                            totalVehicles.toString(),
                            Icons.garage,
                            colorScheme.primary,
                          ),
                          duration: const Duration(milliseconds: 800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppAnimations.scaleIn(
                          _buildStatCard(
                            context,
                            'In\nStock',
                            vehiclesIn.toString(),
                            Icons.inventory_2,
                            AppColors.vehicleIn,
                          ),
                          duration: const Duration(milliseconds: 1000),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppAnimations.scaleIn(
                          _buildStatCard(
                            context,
                            'Sold',
                            vehiclesOut.toString(),
                            Icons.trending_up,
                            AppColors.vehicleOut,
                          ),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      ),
                    ],
                  );
                },
              ),
              duration: const Duration(milliseconds: 600),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultIconColor = iconColor ?? colorScheme.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: defaultIconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: defaultIconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeMenuItem(ThemeProvider themeProvider) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          themeProvider.themeMode == ThemeMode.dark
              ? Icons.dark_mode
              : themeProvider.themeMode == ThemeMode.light
              ? Icons.light_mode
              : Icons.brightness_auto,
          color: Colors.indigo,
          size: 20,
        ),
      ),
      title: Text(
        'Theme',
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        themeProvider.themeMode == ThemeMode.dark
            ? 'Dark theme'
            : themeProvider.themeMode == ThemeMode.light
            ? 'Light theme'
            : 'System theme',
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: DropdownButton<ThemeMode>(
        value: themeProvider.themeMode,
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text('Auto', style: GoogleFonts.poppins(fontSize: 14)),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text('Light', style: GoogleFonts.poppins(fontSize: 14)),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text('Dark', style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
        onChanged: (mode) {
          if (mode != null) {
            themeProvider.setThemeMode(mode);
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              if (context.mounted) {
                AppRoutes.pushReplacement(context, AppRoutes.login);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Logout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _exportVehicleData(BuildContext context) async {
    try {
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load vehicles if not already loaded
      if (vehicleProvider.vehicles.isEmpty && authProvider.token != null) {
        await vehicleProvider.loadVehicles(authProvider.token!);
      }

      final vehicles = vehicleProvider.vehicles;

      if (vehicles.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No vehicles found to export',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      // Create PDF
      final pdf = pw.Document();

      // Load the logo image
      final ByteData logoData = await rootBundle.load('assets/image 1 (1).png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          header: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    // Logo
                    pw.Container(
                      width: 40,
                      height: 40,
                      child: pw.Image(logoImage),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Jivhala Motors',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Vehicle Export Report',
                          style: pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated on:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      DateFormat(
                        'MMM dd, yyyy - hh:mm a',
                      ).format(DateTime.now()),
                      style: pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Total Vehicles: ${vehicles.length}',
                      style: pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          build: (context) => [
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(100),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(80),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Vehicle No.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Chassis No.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Status',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date In',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date Out',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Data rows
                ...vehicles.map(
                  (vehicle) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(vehicle.vehicleNumber),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(vehicle.chassisNo),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(vehicle.status.toUpperCase()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(vehicle.vehicleInDate),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          vehicle.outDate != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(vehicle.outDate!)
                              : '-',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      // Show/Save PDF
      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
            'jivhala_motors_vehicles_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to export data: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.expired,
        ),
      );
    }
  }
}
