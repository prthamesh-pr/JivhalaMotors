import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class VehicleInScreen extends StatefulWidget {
  final Vehicle? vehicle;
  final VoidCallback? onVehicleAdded;

  const VehicleInScreen({super.key, this.vehicle, this.onVehicleAdded});

  @override
  State<VehicleInScreen> createState() => _VehicleInScreenState();
}

class _VehicleInScreenState extends State<VehicleInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _vehicleNumberFocusNode = FocusNode();

  // Form controllers
  final _vehicleInDateController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleHPController = TextEditingController();
  final _chassisNoController = TextEditingController();
  final _engineNoController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _modelYearController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _insuranceDateController = TextEditingController();
  final _challanController = TextEditingController();

  // Form state
  String _selectedOwnerType = '1st';
  bool _hasRC = false;
  bool _hasPUC = false;
  bool _hasNOC = false;
  final List<XFile> _vehiclePhotos = [];
  bool _isLoading = false;

  final List<String> _ownerTypes = ['1st', '2nd', '3rd'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.vehicle == null) {
      // Set default date to today for new vehicle
      _vehicleInDateController.text = DateTime.now().toString().split(' ')[0];
    } else {
      // Populate form for editing
      final vehicle = widget.vehicle!;
      _vehicleInDateController.text = vehicle.vehicleInDate.toString().split(
        ' ',
      )[0];
      _vehicleNumberController.text = vehicle.vehicleNumber;
      _vehicleHPController.text = vehicle.vehicleHP ?? '';
      _chassisNoController.text = vehicle.chassisNo;
      _engineNoController.text = vehicle.engineNo;
      _vehicleNameController.text = vehicle.vehicleName;
      _modelYearController.text = vehicle.modelYear.toString();
      _ownerNameController.text = vehicle.ownerName;
      _selectedOwnerType = vehicle.ownerType;
      _mobileNoController.text = vehicle.mobileNo;
      _insuranceDateController.text =
          vehicle.insuranceDate?.toString().split(' ')[0] ?? '';
      _challanController.text = vehicle.challan ?? '';
      _hasRC = vehicle.documents.rc;
      _hasPUC = vehicle.documents.puc;
      _hasNOC = vehicle.documents.noc;
    }
  }

  @override
  void dispose() {
    _vehicleInDateController.dispose();
    _vehicleNumberController.dispose();
    _vehicleHPController.dispose();
    _chassisNoController.dispose();
    _engineNoController.dispose();
    _vehicleNameController.dispose();
    _modelYearController.dispose();
    _ownerNameController.dispose();
    _mobileNoController.dispose();
    _insuranceDateController.dispose();
    _challanController.dispose();
    _scrollController.dispose();
    _vehicleNumberFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toString().split(' ')[0];
    }
  }

  Future<void> _submitForm() async {
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

      // Create vehicle data
      final vehicleData = <String, dynamic>{
        'vehicleInDate': _vehicleInDateController.text,
        'vehicleNumber': _vehicleNumberController.text.toUpperCase().trim(),
        'vehicleHP': _vehicleHPController.text.trim(),
        'chassisNo': _chassisNoController.text.toUpperCase().trim(),
        'engineNo': _engineNoController.text.toUpperCase().trim(),
        'vehicleName': _vehicleNameController.text.trim(),
        'modelYear': _modelYearController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'ownerType': _selectedOwnerType,
        'mobileNo': _mobileNoController.text.trim(),
        'RC': _hasRC,
        'PUC': _hasPUC,
        'NOC': _hasNOC,
      };

      // Add optional fields only if they have values
      if (_insuranceDateController.text.isNotEmpty) {
        vehicleData['insuranceDate'] = _insuranceDateController.text;
      }
      if (_challanController.text.isNotEmpty) {
        vehicleData['challan'] = _challanController.text.trim();
      }

      bool success;
      if (widget.vehicle == null) {
        // Add new vehicle
        success = await vehicleProvider.createVehicle(
          authProvider.token!,
          vehicleData,
          _vehiclePhotos.isNotEmpty ? _vehiclePhotos : null,
        );
      } else {
        // Update existing vehicle
        success = await vehicleProvider.updateVehicle(
          authProvider.token!,
          widget.vehicle!.id,
          vehicleData,
          _vehiclePhotos.isNotEmpty ? _vehiclePhotos : null,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vehicle == null
                  ? 'Vehicle added successfully'
                  : 'Vehicle updated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback if provided (used when called from dashboard)
        if (widget.onVehicleAdded != null && widget.vehicle == null) {
          widget.onVehicleAdded!();
        } else {
          // Standard navigation for regular screens
          Navigator.of(context).pop();
        }
      } else if (mounted) {
        String errorMessage =
            vehicleProvider.errorMessage ?? 'Operation failed';

        // Handle duplicate vehicle number error with helpful dialog
        if (errorMessage.toLowerCase().contains(
          'vehicle with this number already exists',
        )) {
          _showDuplicateVehicleDialog(
            _vehicleNumberController.text.toUpperCase(),
          );
          return; // Don't show the regular snackbar
        } else if (errorMessage.toLowerCase().contains(
          'vehicle with this chassis number already exists',
        )) {
          _showDuplicateChassisDialog(_chassisNoController.text.toUpperCase());
          return; // Don't show the regular snackbar
        } else if (errorMessage.toLowerCase().contains(
          'vehicle with this engine number already exists',
        )) {
          _showDuplicateEngineDialog(_engineNoController.text.toUpperCase());
          return; // Don't show the regular snackbar
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
            duration: const Duration(
              seconds: 4,
            ), // Show longer for error messages
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

  void _showDuplicateVehicleDialog(String vehicleNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            'Vehicle Number Already Exists',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A vehicle with number "$vehicleNumber" already exists in the system.',
                style: GoogleFonts.poppins(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Verify the vehicle number is correct\n'
                '• Check if this vehicle was already added\n'
                '• Use a different vehicle number if needed',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Focus on the vehicle number field for editing
                _vehicleNumberFocusNode.requestFocus();
                Future.delayed(const Duration(milliseconds: 100), () {
                  _vehicleNumberController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _vehicleNumberController.text.length,
                  );
                });
              },
              child: Text(
                'Edit Number',
                style: GoogleFonts.poppins(color: colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showDuplicateChassisDialog(String chassisNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            'Chassis Number Already Exists',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A vehicle with chassis number "$chassisNumber" already exists in the system.',
                style: GoogleFonts.poppins(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Verify the chassis number is correct\n'
                '• Check if this vehicle was already added\n'
                '• Each vehicle must have a unique chassis number',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Edit Chassis Number',
                style: GoogleFonts.poppins(color: colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  void _showDuplicateEngineDialog(String engineNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Text(
            'Engine Number Already Exists',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A vehicle with engine number "$engineNumber" already exists in the system.',
                style: GoogleFonts.poppins(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                'Please check:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Verify the engine number is correct\n'
                '• Check if this vehicle was already added\n'
                '• Each vehicle must have a unique engine number',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Edit Engine Number',
                style: GoogleFonts.poppins(color: colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text('OK', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Vehicle Information'),
              const SizedBox(height: 16),

              // Vehicle In Date
              InkWell(
                onTap: () => _selectDate(_vehicleInDateController),
                child: IgnorePointer(
                  child: CommonWidgets.customTextField(
                    label: 'Vehicle In Date *',
                    controller: _vehicleInDateController,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Date is required' : null,
                    suffixIcon: const Icon(Icons.calendar_today),
                    context: context,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Vehicle Number
              CommonWidgets.customTextField(
                label: 'Vehicle Number *',
                controller: _vehicleNumberController,
                focusNode: _vehicleNumberFocusNode,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Vehicle number is required';
                  }
                  return null;
                },
                context: context,
              ),

              const SizedBox(height: 16),

              // Vehicle HP
              CommonWidgets.customTextField(
                label: 'Vehicle HP',
                controller: _vehicleHPController,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 16),

              // Chassis Number
              CommonWidgets.customTextField(
                label: 'Chassis Number *',
                controller: _chassisNoController,
                keyboardType: TextInputType.text,
                validator: (value) => value?.isEmpty == true
                    ? 'Chassis number is required'
                    : null,
              ),

              const SizedBox(height: 16),

              // Engine Number
              CommonWidgets.customTextField(
                label: 'Engine Number *',
                controller: _engineNoController,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value?.isEmpty == true ? 'Engine number is required' : null,
              ),

              const SizedBox(height: 16),

              // Vehicle Name
              CommonWidgets.customTextField(
                label: 'Vehicle Name *',
                controller: _vehicleNameController,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value?.isEmpty == true ? 'Vehicle name is required' : null,
              ),

              const SizedBox(height: 16),

              // Model Year
              CommonWidgets.customTextField(
                label: 'Model Year *',
                controller: _modelYearController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Model year is required';
                  final year = int.tryParse(value!);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Owner Information'),
              const SizedBox(height: 16),

              // Owner Name
              CommonWidgets.customTextField(
                label: 'Owner Name *',
                controller: _ownerNameController,
                keyboardType: TextInputType.text,
                validator: (value) =>
                    value?.isEmpty == true ? 'Owner name is required' : null,
              ),

              const SizedBox(height: 16),

              // Owner Type
              DropdownButtonFormField<String>(
                value: _selectedOwnerType,
                decoration: InputDecoration(
                  labelText: 'Owner Type *',
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
                items: _ownerTypes.map((type) {
                  String displayText;
                  switch (type) {
                    case '1st':
                      displayText = '1st Owner';
                      break;
                    case '2nd':
                      displayText = '2nd Owner';
                      break;
                    case '3rd':
                      displayText = '3rd Owner';
                      break;
                    default:
                      displayText = type;
                  }
                  return DropdownMenuItem(
                    value: type,
                    child: Text(displayText, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOwnerType = value!;
                  });
                },
                validator: (value) =>
                    value?.isEmpty == true ? 'Owner type is required' : null,
              ),

              const SizedBox(height: 16),

              // Mobile Number
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
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Insurance Date
              InkWell(
                onTap: () => _selectDate(_insuranceDateController),
                child: IgnorePointer(
                  child: CommonWidgets.customTextField(
                    label: 'Insurance Date',
                    controller: _insuranceDateController,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Challan
              CommonWidgets.customTextField(
                label: 'Challan',
                controller: _challanController,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Documents'),
              const SizedBox(height: 16),

              // Document Checkboxes
              _buildDocumentCheckbox('RC (Registration Certificate)', _hasRC, (
                value,
              ) {
                setState(() {
                  _hasRC = value;
                });
              }),

              _buildDocumentCheckbox('PUC (Pollution Under Control)', _hasPUC, (
                value,
              ) {
                setState(() {
                  _hasPUC = value;
                });
              }),

              _buildDocumentCheckbox(
                'NOC (No Objection Certificate)',
                _hasNOC,
                (value) {
                  setState(() {
                    _hasNOC = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              _buildSectionTitle('Vehicle Photos'),
              const SizedBox(height: 16),

              // Photo picker
              CommonWidgets.buildPhotoPicker(
                photos: _vehiclePhotos,
                onAdd: (photo) {
                  setState(() {
                    _vehiclePhotos.add(photo);
                  });
                },
                onRemove: (index) {
                  setState(() {
                    _vehiclePhotos.removeAt(index);
                  });
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              CommonWidgets.customButton(
                label: widget.vehicle == null
                    ? 'Add Vehicle'
                    : 'Update Vehicle',
                onPressed: _submitForm,
                width: double.infinity,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildDocumentCheckbox(
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, color: colorScheme.onSurface),
      ),
      value: value,
      onChanged: (newValue) => onChanged(newValue ?? false),
      activeColor: colorScheme.primary,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
