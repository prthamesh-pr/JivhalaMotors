import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../widgets/common_widgets.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSortBy = 'Date (Newest)';

  final List<String> _filterOptions = ['All', 'In', 'Out', 'Sold'];
  final List<String> _sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'Vehicle Number (A-Z)',
    'Vehicle Number (Z-A)',
    'Owner Name (A-Z)',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vehicleProvider = Provider.of<VehicleProvider>(
        context,
        listen: false,
      );
      if (authProvider.token != null) {
        vehicleProvider.loadVehicles(authProvider.token!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Vehicles',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.token != null) {
                Provider.of<VehicleProvider>(
                  context,
                  listen: false,
                ).loadVehicles(authProvider.token!);
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (vehicleProvider.isLoading) {
            return CommonWidgets.loadingWidget();
          }

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar
                    CommonWidgets.customTextField(
                      label: 'Search vehicles...',
                      controller: _searchController,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : const Icon(Icons.search),
                    ),

                    const SizedBox(height: 12),

                    // Filter and Sort Row
                    Row(
                      children: [
                        // Filter Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedFilter,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              items: _filterOptions.map((filter) {
                                return DropdownMenuItem(
                                  value: filter,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.filter_list,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        filter,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedFilter = value!;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Sort Dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedSortBy,
                              isExpanded: true,
                              underline: const SizedBox.shrink(),
                              items: _sortOptions.map((sort) {
                                return DropdownMenuItem(
                                  value: sort,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.sort,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          sort,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSortBy = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Vehicle Statistics
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                color: Colors.grey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      'Total',
                      vehicleProvider.vehicles.length.toString(),
                      Colors.blue,
                    ),
                    _buildStatChip(
                      'In Stock',
                      vehicleProvider.vehicles
                          .where((v) => v.status.toLowerCase() == 'in')
                          .length
                          .toString(),
                      Colors.green,
                    ),
                    _buildStatChip(
                      'Sold',
                      vehicleProvider.vehicles
                          .where((v) => v.status.toLowerCase() == 'out')
                          .length
                          .toString(),
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              // Vehicle List
              Expanded(child: _buildVehiclesList(vehicleProvider.vehicles)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.push(context, AppRoutes.vehicleIn);
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatChip(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildVehiclesList(List<Vehicle> vehicles) {
    // Apply search filter
    List<Vehicle> filteredVehicles = vehicles.where((vehicle) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          vehicle.vehicleNumber.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          vehicle.chassisNo.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          vehicle.vehicleName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          vehicle.ownerName.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      final matchesFilter =
          _selectedFilter == 'All' ||
          vehicle.status.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();

    // Apply sorting
    switch (_selectedSortBy) {
      case 'Date (Newest)':
        filteredVehicles.sort(
          (a, b) => b.vehicleInDate.compareTo(a.vehicleInDate),
        );
        break;
      case 'Date (Oldest)':
        filteredVehicles.sort(
          (a, b) => a.vehicleInDate.compareTo(b.vehicleInDate),
        );
        break;
      case 'Vehicle Number (A-Z)':
        filteredVehicles.sort(
          (a, b) => a.vehicleNumber.compareTo(b.vehicleNumber),
        );
        break;
      case 'Vehicle Number (Z-A)':
        filteredVehicles.sort(
          (a, b) => b.vehicleNumber.compareTo(a.vehicleNumber),
        );
        break;
      case 'Owner Name (A-Z)':
        filteredVehicles.sort((a, b) => a.ownerName.compareTo(b.ownerName));
        break;
    }

    if (filteredVehicles.isEmpty) {
      return CommonWidgets.emptyStateWidget(
        message: vehicles.isEmpty
            ? 'No vehicles added yet'
            : 'No vehicles match your search criteria',
        icon: vehicles.isEmpty
            ? Icons.directions_car_outlined
            : Icons.search_off,
        actionText: vehicles.isEmpty ? 'Add Vehicle' : null,
        onAction: vehicles.isEmpty
            ? () => AppRoutes.push(context, AppRoutes.vehicleIn)
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.token != null) {
          await Provider.of<VehicleProvider>(
            context,
            listen: false,
          ).loadVehicles(authProvider.token!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredVehicles.length,
        itemBuilder: (context, index) {
          final vehicle = filteredVehicles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildVehicleCard(vehicle),
          );
        },
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          AppRoutes.push(context, AppRoutes.vehicleDetails, arguments: vehicle);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.vehicleNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.vehicleName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonWidgets.vehicleStatusChip(vehicle.status),
                ],
              ),

              const SizedBox(height: 12),

              // Vehicle Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.engineering,
                      'Chassis',
                      vehicle.chassisNo,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.calendar_today,
                      'Year',
                      vehicle.modelYear.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      Icons.person,
                      'Owner',
                      vehicle.ownerName,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      Icons.phone,
                      'Mobile',
                      vehicle.mobileNo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _buildDetailItem(
                Icons.access_time,
                'Added',
                _formatDate(vehicle.vehicleInDate),
              ),

              // Action Buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppRoutes.push(
                          context,
                          AppRoutes.vehicleIn,
                          arguments: vehicle,
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(
                        'Edit',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (vehicle.status.toLowerCase() == 'in')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          AppRoutes.push(
                            context,
                            AppRoutes.vehicleOut,
                            arguments: vehicle,
                          );
                        },
                        icon: const Icon(Icons.exit_to_app, size: 16),
                        label: Text(
                          'Mark Out',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
