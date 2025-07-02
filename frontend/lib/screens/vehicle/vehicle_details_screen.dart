import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/image_utils.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 12),
                    Text('Edit', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    const Icon(Icons.print, size: 20),
                    const SizedBox(width: 12),
                    Text('Print', style: GoogleFonts.poppins()),
                  ],
                ),
              ),
              if (vehicle.status.toLowerCase() == 'in')
                PopupMenuItem(
                  value: 'vehicle_out',
                  child: Row(
                    children: [
                      const Icon(Icons.exit_to_app, size: 20),
                      const SizedBox(width: 12),
                      Text('Vehicle Out', style: GoogleFonts.poppins()),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(),
            const SizedBox(height: 24),

            // Vehicle Information
            _buildInfoSection('Vehicle Information', [
              _buildInfoRow('Vehicle Number', vehicle.vehicleNumber),
              _buildInfoRow('Vehicle Name', vehicle.vehicleName),
              _buildInfoRow('Chassis Number', vehicle.chassisNo),
              _buildInfoRow('Engine Number', vehicle.engineNo),
              _buildInfoRow('Model Year', vehicle.modelYear.toString()),
              if (vehicle.vehicleHP != null)
                _buildInfoRow('Vehicle HP', vehicle.vehicleHP!),
              _buildInfoRow(
                'Vehicle In Date',
                _formatDate(vehicle.vehicleInDate),
              ),
              if (vehicle.insuranceDate != null)
                _buildInfoRow(
                  'Insurance Date',
                  _formatDate(vehicle.insuranceDate!),
                ),
              if (vehicle.challan != null && vehicle.challan!.isNotEmpty)
                _buildInfoRow('Challan', vehicle.challan!),
            ]),

            const SizedBox(height: 24),

            // Owner Information
            _buildInfoSection('Owner Information', [
              _buildInfoRow('Owner Name', vehicle.ownerName),
              _buildInfoRow('Owner Type', vehicle.ownerType),
              _buildInfoRow('Mobile Number', vehicle.mobileNo),
            ]),

            const SizedBox(height: 24),

            // Documents
            _buildDocumentsSection(),

            const SizedBox(height: 24),

            // Photos
            if (vehicle.photos.isNotEmpty) _buildPhotosSection(),

            // Buyer Information (only if vehicle is marked out)
            if (vehicle.status.toLowerCase() == 'out' && vehicle.buyer != null) ...[
              const SizedBox(height: 24),
              _buildBuyerSection(),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.car_detailed,
                color: Colors.indigo,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleNumber,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.vehicleName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            CommonWidgets.vehicleStatusChip(vehicle.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDocumentChip('RC', vehicle.documents.rc)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDocumentChip('PUC', vehicle.documents.puc),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDocumentChip('NOC', vehicle.documents.noc),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentChip(String label, bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: available
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: available
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: available ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: available ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photos (${vehicle.photos.length})',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: vehicle.photos.length,
              itemBuilder: (context, index) {
                final photo = vehicle.photos[index];
                final imageUrl = ImageUtils.getImageUrl(
                  photo.path,
                  photoUrl: photo.url,
                );

                return GestureDetector(
                  onTap: () => _showImagePreview(context, photo),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.grey[300],
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, VehiclePhoto photo) {
    final imageUrl = ImageUtils.getImageUrl(photo.path, photoUrl: photo.url);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBuyerSection() {
    final buyer = vehicle.buyer!;
    return _buildInfoSection('Buyer Information', [
      _buildInfoRow('Buyer Name', buyer.buyerName ?? 'N/A'),
      _buildInfoRow('Address', buyer.address ?? 'N/A'),
      _buildInfoRow('Mobile Number', buyer.mobileNo ?? 'N/A'),
      if (buyer.idProofType != null)
        _buildInfoRow('ID Proof Type', buyer.idProofType!),
      if (buyer.aadharCard != null && buyer.aadharCard!.isNotEmpty)
        _buildInfoRow('Aadhar Card', buyer.aadharCard!),
      if (buyer.panCard != null && buyer.panCard!.isNotEmpty)
        _buildInfoRow('PAN Card', buyer.panCard!),
      if (buyer.dlNumber != null && buyer.dlNumber!.isNotEmpty)
        _buildInfoRow('DL Number', buyer.dlNumber!),
      if (buyer.price != null)
        _buildInfoRow('Price', '₹${buyer.price!.toStringAsFixed(2)}'),
      if (buyer.rtoCharges != null)
        _buildInfoRow('RTO Charges', '₹${buyer.rtoCharges!.toStringAsFixed(2)}'),
      if (buyer.commission != null)
        _buildInfoRow('Commission', '₹${buyer.commission!.toStringAsFixed(2)}'),
      if (buyer.token != null)
        _buildInfoRow('Token', '₹${buyer.token!.toStringAsFixed(2)}'),
      if (buyer.receivedPrice != null)
        _buildInfoRow('Received', '₹${buyer.receivedPrice!.toStringAsFixed(2)}'),
      if (buyer.balance != null)
        _buildInfoRow('Balance', '₹${buyer.balance!.toStringAsFixed(2)}'),
    ]);
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CommonWidgets.customButton(
                label: 'Edit',
                onPressed: () => _handleMenuAction(context, 'edit'),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommonWidgets.customButton(
                label: 'Print',
                onPressed: () => _handleMenuAction(context, 'print'),
                color: Colors.green,
              ),
            ),
          ],
        ),
        if (vehicle.status.toLowerCase() == 'in') ...[
          const SizedBox(height: 12),
          CommonWidgets.customButton(
            label: 'Mark as Out',
            onPressed: () => _handleMenuAction(context, 'vehicle_out'),
            width: double.infinity,
            color: Colors.orange,
          ),
        ],
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        // Capture providers before navigation
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final vehicleProvider = Provider.of<VehicleProvider>(
          context,
          listen: false,
        );

        Navigator.of(
          context,
        ).pushNamed(AppRoutes.vehicleIn, arguments: vehicle).then((_) {
          // Refresh the vehicle data if needed
          if (authProvider.token != null) {
            vehicleProvider.loadVehicles(authProvider.token!);
          }
        });
        break;
      case 'print':
        _printVehicleDetails(context);
        break;
      case 'vehicle_out':
        // Capture providers before navigation
        final authProvider2 = Provider.of<AuthProvider>(context, listen: false);
        final vehicleProvider2 = Provider.of<VehicleProvider>(
          context,
          listen: false,
        );

        Navigator.of(
          context,
        ).pushNamed(AppRoutes.vehicleOut, arguments: vehicle).then((_) {
          // Refresh the vehicle data
          if (authProvider2.token != null) {
            vehicleProvider2.loadVehicles(authProvider2.token!);
          }
        });
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  Future<void> _printVehicleDetails(BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Load a font that supports Unicode characters
      final font = await PdfGoogleFonts.notoSansRegular();
      final boldFont = await PdfGoogleFonts.notoSansBold();

      // Load logo image
      final logoBytes = await rootBundle.load('assets/image 1 (1).png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
          build: (pw.Context context) {
            return [
              // Header
              pw.Column(
                children: [
                  // Logo and Company Name
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          // Logo
                          pw.Container(
                            width: 50,
                            height: 50,
                            child: pw.Image(logoImage),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Jivhala Motors',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  font: boldFont,
                                ),
                              ),
                              pw.Text(
                                'Your Trusted Vehicle Partner',
                                style: pw.TextStyle(fontSize: 12, font: font),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                'Address: Shop No. 123, Vehicle Market, City',
                                style: pw.TextStyle(fontSize: 10, font: font),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Contact: +91-XXXXXXXXXX',
                            style: pw.TextStyle(fontSize: 10, font: font),
                          ),
                          pw.Text(
                            'Email: info@jivhalamotors.com',
                            style: pw.TextStyle(fontSize: 10, font: font),
                          ),
                          pw.Text(
                            'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: pw.TextStyle(fontSize: 10, font: font),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  // Title
                  pw.Center(
                    child: pw.Text(
                      'VEHICLE DETAILS',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: boldFont,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Vehicle Details Box
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(8),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Vehicle Information',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            font: boldFont,
                          ),
                        ),
                        pw.SizedBox(height: 16),

                        // Vehicle Information Grid
                        pw.Table(
                          columnWidths: {
                            0: const pw.FixedColumnWidth(120),
                            1: const pw.FlexColumnWidth(),
                            2: const pw.FixedColumnWidth(120),
                            3: const pw.FlexColumnWidth(),
                          },
                          children: [
                            _buildTableRow(
                              'Vehicle Number:',
                              vehicle.vehicleNumber,
                              'Vehicle Name:',
                              vehicle.vehicleName,
                              font,
                            ),
                            _buildTableRow(
                              'Chassis No:',
                              vehicle.chassisNo,
                              'Engine No:',
                              vehicle.engineNo,
                              font,
                            ),
                            _buildTableRow(
                              'Model Year:',
                              vehicle.modelYear.toString(),
                              'Vehicle HP:',
                              vehicle.vehicleHP ?? 'N/A',
                              font,
                            ),
                            _buildTableRow(
                              'Owner Name:',
                              vehicle.ownerName,
                              'Owner Type:',
                              vehicle.ownerType,
                              font,
                            ),
                            _buildTableRow(
                              'Mobile No:',
                              vehicle.mobileNo,
                              'In Date:',
                              _formatDate(vehicle.vehicleInDate),
                              font,
                            ),
                            if (vehicle.insuranceDate != null)
                              _buildTableRow(
                                'Insurance Date:',
                                _formatDate(vehicle.insuranceDate!),
                                'Challan:',
                                vehicle.challan ?? 'N/A',
                                font,
                              ),
                          ],
                        ),

                        pw.SizedBox(height: 16),

                        // Documents
                        pw.Text(
                          'Documents:',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            font: boldFont,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Row(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4),
                                ),
                              ),
                              child: pw.Text(
                                'RC: ${vehicle.documents.rc ? 'Yes' : 'No'}',
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4),
                                ),
                              ),
                              child: pw.Text(
                                'PUC: ${vehicle.documents.puc ? 'Yes' : 'No'}',
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(),
                                borderRadius: const pw.BorderRadius.all(
                                  pw.Radius.circular(4),
                                ),
                              ),
                              child: pw.Text(
                                'NOC: ${vehicle.documents.noc ? 'Yes' : 'No'}',
                                style: pw.TextStyle(font: font),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Buyer Details (only if vehicle is sold/out)
                  if (vehicle.status.toLowerCase() == 'out' && vehicle.buyer != null) ...[
                    pw.Container(
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Buyer Information',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                          pw.SizedBox(height: 16),

                          pw.Table(
                            columnWidths: {
                              0: const pw.FixedColumnWidth(120),
                              1: const pw.FlexColumnWidth(),
                              2: const pw.FixedColumnWidth(120),
                              3: const pw.FlexColumnWidth(),
                            },
                            children: [
                              _buildTableRow(
                                'Buyer Name:',
                                vehicle.buyer!.buyerName ?? '',
                                'Address:',
                                vehicle.buyer!.address ?? '',
                                font,
                              ),
                              _buildTableRow(
                                'Mobile No:',
                                vehicle.buyer!.mobileNo ?? '',
                                'ID Proof:',
                                vehicle.buyer!.idProofType ?? '',
                                font,
                              ),
                              _buildTableRow(
                                'Price:',
                                '₹${vehicle.buyer!.price?.toStringAsFixed(2) ?? '0.00'}',
                                'RTO Charges:',
                                '₹${vehicle.buyer!.rtoCharges?.toStringAsFixed(2) ?? '0.00'}',
                                font,
                              ),
                              _buildTableRow(
                                'Commission:',
                                '₹${vehicle.buyer!.commission?.toStringAsFixed(2) ?? '0.00'}',
                                'Token:',
                                '₹${vehicle.buyer!.token?.toStringAsFixed(2) ?? '0.00'}',
                                font,
                              ),
                              _buildTableRow(
                                'Received:',
                                '₹${vehicle.buyer!.receivedPrice?.toStringAsFixed(2) ?? '0.00'}',
                                'Balance:',
                                '₹${vehicle.buyer!.balance?.toStringAsFixed(2) ?? '0.00'}',
                                font,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 30),
                  ],

                  // Signature Section - Show both signatures only if vehicle is sold
                  pw.Row(
                    mainAxisAlignment: vehicle.status.toLowerCase() == 'out'
                        ? pw.MainAxisAlignment.spaceBetween
                        : pw.MainAxisAlignment.center,
                    children: [
                      pw.Column(
                        children: [
                          pw.Container(
                            width: 150,
                            height: 1,
                            color: PdfColors.black,
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'Owner Signature',
                            style: pw.TextStyle(font: font),
                          ),
                        ],
                      ),
                      if (vehicle.status.toLowerCase() == 'out' && vehicle.buyer != null)
                        pw.Column(
                          children: [
                            pw.Container(
                              width: 150,
                              height: 1,
                              color: PdfColors.black,
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'Buyer Signature',
                              style: pw.TextStyle(font: font),
                            ),
                          ],
                        ),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  // Footer
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Thank you for trusting Jivhala Motors!',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            font: boldFont,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Designed and Developed by 5TechG',
                          style: pw.TextStyle(fontSize: 10, font: font),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: '${vehicle.vehicleNumber}_details.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error printing: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.TableRow _buildTableRow(
    String label1,
    String value1,
    String label2,
    String value2,
    pw.Font font,
  ) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label1,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              font: font,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(value1, style: pw.TextStyle(fontSize: 10, font: font)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            label2,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              font: font,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(value2, style: pw.TextStyle(fontSize: 10, font: font)),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Vehicle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
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

              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              final vehicleProvider = Provider.of<VehicleProvider>(
                context,
                listen: false,
              );

              if (authProvider.token != null) {
                final success = await vehicleProvider.deleteVehicle(
                  authProvider.token!,
                  vehicle.id,
                );

                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Vehicle deleted successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        vehicleProvider.errorMessage ??
                            'Failed to delete vehicle',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
