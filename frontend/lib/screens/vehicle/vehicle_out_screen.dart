import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class VehicleOutScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleOutScreen({super.key, required this.vehicle});

  @override
  State<VehicleOutScreen> createState() => _VehicleOutScreenState();
}

class _VehicleOutScreenState extends State<VehicleOutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Buyer Information Controllers
  final _buyerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _aadharCardController = TextEditingController();
  final _panCardController = TextEditingController();
  final _dlNumberController = TextEditingController();

  // Financial Controllers
  final _priceController = TextEditingController();
  final _rtoChargesController = TextEditingController();
  final _commissionController = TextEditingController();
  final _tokenController = TextEditingController();
  final _receivedPriceController = TextEditingController();
  final _balanceController = TextEditingController();

  // Form State
  String _selectedIdProofType = 'Aadhar Card';
  XFile? _buyerPhoto;
  bool _isLoading = false;

  final List<String> _idProofTypes = [
    'Aadhar Card',
    'PAN Card',
    'Driving License',
    'Voter ID',
    'Passport',
  ];

  final Map<String, String> _idProofTypeMapping = {
    'Aadhar Card': 'Aadhaar',
    'PAN Card': 'PAN',
    'Driving License': 'DL',
    'Voter ID': 'Voter',
    'Passport': 'Passport',
  };

  @override
  void initState() {
    super.initState();
    _setupCalculations();
    _loadExistingBuyerData();
  }

  void _loadExistingBuyerData() {
    // If vehicle is already marked out and has buyer data, populate the form
    if (widget.vehicle.status.toLowerCase() == 'out' && widget.vehicle.buyer != null) {
      final buyer = widget.vehicle.buyer!;
      
      _buyerNameController.text = buyer.buyerName ?? '';
      _addressController.text = buyer.address ?? '';
      _mobileNoController.text = buyer.mobileNo ?? '';
      _priceController.text = buyer.price?.toStringAsFixed(2) ?? '';
      _rtoChargesController.text = buyer.rtoCharges?.toStringAsFixed(2) ?? '';
      _commissionController.text = buyer.commission?.toStringAsFixed(2) ?? '';
      _tokenController.text = buyer.token?.toStringAsFixed(2) ?? '';
      _receivedPriceController.text = buyer.receivedPrice?.toStringAsFixed(2) ?? '';
      _balanceController.text = buyer.balance?.toStringAsFixed(2) ?? '';
      _aadharCardController.text = buyer.aadharCard ?? '';
      _panCardController.text = buyer.panCard ?? '';
      _dlNumberController.text = buyer.dlNumber ?? '';
      
      // Set ID proof type
      if (buyer.idProofType != null) {
        final reverseMapping = {
          'Aadhaar': 'Aadhar Card',
          'PAN': 'PAN Card',
          'DL': 'Driving License',
          'Voter': 'Voter ID',
          'Passport': 'Passport',
        };
        _selectedIdProofType = reverseMapping[buyer.idProofType] ?? 'Aadhar Card';
      }
    }
  }

  void _setupCalculations() {
    // Add listeners for automatic calculations
    _priceController.addListener(_calculateBalance);
    _rtoChargesController.addListener(_calculateBalance);
    _commissionController.addListener(_calculateBalance);
    _tokenController.addListener(_calculateBalance);
    _receivedPriceController.addListener(_calculateBalance);
  }

  void _calculateBalance() {
    try {
      final price = double.tryParse(_priceController.text) ?? 0;
      final rtoCharges = double.tryParse(_rtoChargesController.text) ?? 0;
      final commission = double.tryParse(_commissionController.text) ?? 0;
      final token = double.tryParse(_tokenController.text) ?? 0;
      final receivedPrice = double.tryParse(_receivedPriceController.text) ?? 0;

      final totalAmount = price + rtoCharges + commission;
      final balance = totalAmount - token - receivedPrice;

      _balanceController.text = balance.toStringAsFixed(2);
    } catch (e) {
      // Handle calculation errors silently
    }
  }

  @override
  void dispose() {
    _buyerNameController.dispose();
    _addressController.dispose();
    _mobileNoController.dispose();
    _aadharCardController.dispose();
    _panCardController.dispose();
    _dlNumberController.dispose();
    _priceController.dispose();
    _rtoChargesController.dispose();
    _commissionController.dispose();
    _tokenController.dispose();
    _receivedPriceController.dispose();
    _balanceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickBuyerPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() {
        _buyerPhoto = photo;
      });
    }
  }

  Future<void> _markVehicleOut() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );

      if (authProvider.token == null) {
        throw Exception('Not authenticated');
      }

      // Create buyer data with proper data type handling
      final buyerData = {
        'buyerName': _buyerNameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobileNo': _mobileNoController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'rtoCharges': double.tryParse(_rtoChargesController.text.trim()) ?? 0.0,
        'commission': double.tryParse(_commissionController.text.trim()) ?? 0.0,
        'token': double.tryParse(_tokenController.text.trim()) ?? 0.0,
        'receivedPrice':
            double.tryParse(_receivedPriceController.text.trim()) ?? 0.0,
        'balance': double.tryParse(_balanceController.text.trim()) ?? 0.0,
        'aadharCard': _aadharCardController.text.trim(),
        'panCard': _panCardController.text.trim(),
        'dlNumber': _dlNumberController.text.trim(),
        'idProofType':
            _idProofTypeMapping[_selectedIdProofType] ?? _selectedIdProofType,
      };

      // Validate required fields before sending
      final buyerName = buyerData['buyerName'] as String;
      final address = buyerData['address'] as String;
      final mobileNo = buyerData['mobileNo'] as String;
      final price = buyerData['price'] as double;

      if (buyerName.isEmpty) {
        throw Exception('Buyer name is required');
      }
      if (address.isEmpty) {
        throw Exception('Address is required');
      }
      if (mobileNo.isEmpty) {
        throw Exception('Mobile number is required');
      }
      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobileNo)) {
        throw Exception(
          'Mobile number must be a valid 10-digit number starting with 6, 7, 8, or 9',
        );
      }
      if (price <= 0) {
        throw Exception('Vehicle price must be greater than 0');
      }

      final success = await vehicleProvider.markVehicleOut(
        authProvider.token!,
        widget.vehicle.id,
        buyerData,
        _buyerPhoto,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vehicle marked as out successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vehicleProvider.errorMessage ?? 'Failed to mark vehicle as out',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _printVehicleOutDetails(BuildContext context) async {
    // Capture ScaffoldMessenger before async operations to avoid context issues
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final pdf = pw.Document();

      // Load a font that supports Unicode characters
      final font = await PdfGoogleFonts.notoSansRegular();
      final boldFont = await PdfGoogleFonts.notoSansBold();

      // Load the logo image
      final ByteData logoData = await rootBundle.load('assets/image 1 (1).png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

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
                      'VEHICLE OUT DETAILS',
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

                        // Vehicle Information
                        pw.Table(
                          columnWidths: {
                            0: const pw.FixedColumnWidth(120),
                            1: const pw.FlexColumnWidth(),
                            2: const pw.FixedColumnWidth(120),
                            3: const pw.FlexColumnWidth(),
                          },
                          children: [
                            _buildTableRowPrint(
                              'Vehicle Number:',
                              widget.vehicle.vehicleNumber,
                              'Vehicle Name:',
                              widget.vehicle.vehicleName,
                              font,
                            ),
                            _buildTableRowPrint(
                              'Chassis No:',
                              widget.vehicle.chassisNo,
                              'Engine No:',
                              widget.vehicle.engineNo,
                              font,
                            ),
                            _buildTableRowPrint(
                              'Model Year:',
                              widget.vehicle.modelYear.toString(),
                              'Vehicle HP:',
                              widget.vehicle.vehicleHP ?? 'N/A',
                              font,
                            ),
                            _buildTableRowPrint(
                              'Insurance Date:',
                              widget.vehicle.insuranceDate != null
                                  ? '${widget.vehicle.insuranceDate!.day}/${widget.vehicle.insuranceDate!.month}/${widget.vehicle.insuranceDate!.year}'
                                  : 'N/A',
                              'Challan:',
                              widget.vehicle.challan ?? 'N/A',
                              font,
                            ),
                            _buildTableRowPrint(
                              'Owner Name:',
                              widget.vehicle.ownerName,
                              'Owner Type:',
                              widget.vehicle.ownerType,
                              font,
                            ),
                            _buildTableRowPrint(
                              'Mobile No:',
                              widget.vehicle.mobileNo,
                              'Vehicle In Date:',
                              '${widget.vehicle.vehicleInDate.day}/${widget.vehicle.vehicleInDate.month}/${widget.vehicle.vehicleInDate.year}',
                              font,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Buyer Details Box
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
                            _buildTableRowPrint(
                              'Buyer Name:',
                              _buyerNameController.text,
                              'Address:',
                              _addressController.text,
                              font,
                            ),
                            _buildTableRowPrint(
                              'Mobile No:',
                              _mobileNoController.text,
                              'ID Proof:',
                              _selectedIdProofType,
                              font,
                            ),
                            _buildTableRowPrint(
                              'Aadhaar Card:',
                              _aadharCardController.text.isNotEmpty
                                  ? _aadharCardController.text
                                  : 'N/A',
                              'PAN Card:',
                              _panCardController.text.isNotEmpty
                                  ? _panCardController.text
                                  : 'N/A',
                              font,
                            ),
                            _buildTableRowPrint(
                              'DL Number:',
                              _dlNumberController.text.isNotEmpty
                                  ? _dlNumberController.text
                                  : 'N/A',
                              '',
                              '',
                              font,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Financial Details Box
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
                          'Financial Details',
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
                            _buildTableRowPrint(
                              'Price:',
                              '₹${_priceController.text}',
                              'RTO Charges:',
                              '₹${_rtoChargesController.text}',
                              font,
                            ),
                            _buildTableRowPrint(
                              'Commission:',
                              '₹${_commissionController.text}',
                              'Token:',
                              '₹${_tokenController.text}',
                              font,
                            ),
                            _buildTableRowPrint(
                              'Received:',
                              '₹${_receivedPriceController.text}',
                              'Balance:',
                              '₹${_balanceController.text}',
                              font,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Document Checklist
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
                          'Document Checklist',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            font: boldFont,
                          ),
                        ),
                        pw.SizedBox(height: 16),

                        pw.Wrap(
                          children: [
                            _buildChecklistItem('[ ] RC Book', font),
                            _buildChecklistItem('[ ] Insurance Papers', font),
                            _buildChecklistItem(
                              '[ ] Pollution Certificate',
                              font,
                            ),
                            _buildChecklistItem('[ ] Service Records', font),
                            _buildChecklistItem('[ ] Original Invoice', font),
                            _buildChecklistItem(
                              '[ ] NOC (if applicable)',
                              font,
                            ),
                            _buildChecklistItem(
                              '[ ] Fitness Certificate',
                              font,
                            ),
                            _buildChecklistItem(
                              '[ ] Tax Payment Receipt',
                              font,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Signature Section - Simple lines instead of boxes
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
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
        name: '${widget.vehicle.vehicleNumber}_out_details.pdf',
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
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

  pw.TableRow _buildTableRowPrint(
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

  pw.Widget _buildChecklistItem(String text, pw.Font font) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 20, bottom: 8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 12, font: font)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Information Card
              _buildVehicleInfoCard(),

              const SizedBox(height: 24),

              // Current Buyer Information (if vehicle is already marked out)
              if (widget.vehicle.status.toLowerCase() == 'out' && widget.vehicle.buyer != null) ...[
                _buildCurrentBuyerInfoCard(),
                const SizedBox(height: 24),
              ],

              // Buyer Information
              _buildSectionTitle(widget.vehicle.status.toLowerCase() == 'out' 
                  ? 'Update Buyer Information' 
                  : 'Buyer Information'),
              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Buyer Name *',
                controller: _buyerNameController,
                validator: (value) =>
                    value?.isEmpty == true ? 'Buyer name is required' : null,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Address *',
                controller: _addressController,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Address is required' : null,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Mobile Number *',
                controller: _mobileNoController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Mobile number is required';
                  }
                  if (value!.length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Mobile number must start with 6, 7, 8, or 9';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ID Proof Type
              DropdownButtonFormField<String>(
                value: _selectedIdProofType,
                decoration: InputDecoration(
                  labelText: 'ID Proof Type *',
                  labelStyle: GoogleFonts.poppins(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _idProofTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIdProofType = value!;
                  });
                },
                validator: (value) =>
                    value?.isEmpty == true ? 'ID proof type is required' : null,
              ),

              const SizedBox(height: 16),

              // ID Proof Numbers
              if (_selectedIdProofType == 'Aadhar Card')
                CommonWidgets.customTextField(
                  label: 'Aadhar Card Number',
                  controller: _aadharCardController,
                  keyboardType: TextInputType.number,
                ),

              if (_selectedIdProofType == 'PAN Card')
                CommonWidgets.customTextField(
                  label: 'PAN Card Number',
                  controller: _panCardController,
                  keyboardType: TextInputType.text,
                ),

              if (_selectedIdProofType == 'Driving License')
                CommonWidgets.customTextField(
                  label: 'Driving License Number',
                  controller: _dlNumberController,
                  keyboardType: TextInputType.text,
                ),

              const SizedBox(height: 16),

              // Buyer Photo
              _buildBuyerPhotoSection(),

              const SizedBox(height: 24),

              // Financial Information
              _buildSectionTitle('Financial Information'),
              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Vehicle Price (₹) *',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty == true ? 'Price is required' : null,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'RTO Charges (₹)',
                controller: _rtoChargesController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Commission (₹)',
                controller: _commissionController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Token Amount (₹)',
                controller: _tokenController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Received Amount (₹)',
                controller: _receivedPriceController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              CommonWidgets.customTextField(
                label: 'Balance Amount (₹)',
                controller: _balanceController,
                enabled: false,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CommonWidgets.customButton(
                      label: 'Print Details',
                      onPressed: () => _printVehicleOutDetails(context),
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonWidgets.customButton(
                      label: 'Mark as Out',
                      onPressed: _markVehicleOut,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Vehicle Number', widget.vehicle.vehicleNumber),
            _buildInfoRow('Vehicle Name', widget.vehicle.vehicleName),
            _buildInfoRow('Chassis Number', widget.vehicle.chassisNo),
            _buildInfoRow('Engine Number', widget.vehicle.engineNo),
            _buildInfoRow('Owner Name', widget.vehicle.ownerName),
            _buildInfoRow('Mobile Number', widget.vehicle.mobileNo),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildBuyerPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buyer Photo',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickBuyerPhoto,
          child: Container(
            width: double.infinity,
            height: _buyerPhoto != null ? 200 : 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _buyerPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: _buyerPhoto!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                            },
                          )
                        : Image.file(
                            File(_buyerPhoto!.path),
                            fit: BoxFit.cover,
                          ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to take buyer photo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentBuyerInfoCard() {
    final buyer = widget.vehicle.buyer!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Buyer Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vehicle is already marked out',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'OUT',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCurrentBuyerInfoRow('Buyer Name', buyer.buyerName ?? 'N/A'),
            _buildCurrentBuyerInfoRow('Address', buyer.address ?? 'N/A'),
            _buildCurrentBuyerInfoRow('Mobile Number', buyer.mobileNo ?? 'N/A'),
            if (buyer.idProofType != null)
              _buildCurrentBuyerInfoRow('ID Proof Type', buyer.idProofType!),
            if (buyer.price != null)
              _buildCurrentBuyerInfoRow('Price', '₹${buyer.price!.toStringAsFixed(2)}'),
            if (buyer.rtoCharges != null)
              _buildCurrentBuyerInfoRow('RTO Charges', '₹${buyer.rtoCharges!.toStringAsFixed(2)}'),
            if (buyer.commission != null)
              _buildCurrentBuyerInfoRow('Commission', '₹${buyer.commission!.toStringAsFixed(2)}'),
            if (buyer.token != null)
              _buildCurrentBuyerInfoRow('Token', '₹${buyer.token!.toStringAsFixed(2)}'),
            if (buyer.receivedPrice != null)
              _buildCurrentBuyerInfoRow('Received', '₹${buyer.receivedPrice!.toStringAsFixed(2)}'),
            if (buyer.balance != null)
              _buildCurrentBuyerInfoRow('Balance', '₹${buyer.balance!.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBuyerInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
