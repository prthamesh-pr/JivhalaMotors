import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/vehicle.dart';
import '../models/dashboard_stats.dart';
import '../services/api_service.dart';

enum VehicleStatus { loading, loaded, error }

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> _vehicles = [];
  DashboardStats? _dashboardStats;
  VehicleStatus _status = VehicleStatus.loaded;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;
  String? _searchQuery;
  String? _statusFilter;
  String? _fromDate;
  String? _toDate;

  // Getters
  List<Vehicle> get vehicles => _vehicles;
  DashboardStats? get dashboardStats => _dashboardStats;
  VehicleStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == VehicleStatus.loading;
  bool get hasMoreData => _hasMoreData;
  String? get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get fromDate => _fromDate;
  String? get toDate => _toDate;

  void _setStatus(VehicleStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  // Load vehicles with filters
  Future<void> loadVehicles(
    String token, {
    bool refresh = false,
    String? search,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      if (refresh) {
        _vehicles.clear();
        _currentPage = 1;
        _hasMoreData = true;
        _searchQuery = search;
        _statusFilter = status;
        _fromDate = fromDate;
        _toDate = toDate;
      }

      if (!_hasMoreData && !refresh) return;

      _setStatus(VehicleStatus.loading);
      _setError(null);

      final response = await ApiService().getVehicles(
        page: _currentPage,
        limit: 10,
        search: _searchQuery,
        status: _statusFilter,
      );

      if (response['vehicles'] != null) {
        try {
          final vehicleList = (response['vehicles'] as List<dynamic>).map((
            json,
          ) {
            try {
              return Vehicle.fromJson(json);
            } catch (e) {
              debugPrint('Error parsing vehicle JSON: $e');
              debugPrint('Problematic vehicle data: $json');
              rethrow;
            }
          }).toList();

          if (refresh) {
            _vehicles = vehicleList;
          } else {
            _vehicles.addAll(vehicleList);
          }

          final pagination = response['pagination'];
          if (pagination != null) {
            _hasMoreData = pagination['currentPage'] < pagination['totalPages'];
            _currentPage++;
          } else {
            _hasMoreData = false;
          }

          _setStatus(VehicleStatus.loaded);
        } catch (parseError) {
          debugPrint('Vehicle parsing error: $parseError');
          _setError('Error parsing vehicle data: ${parseError.toString()}');
          _setStatus(VehicleStatus.error);
        }
      } else {
        _setError(response['message'] ?? 'Failed to load vehicles');
        _setStatus(VehicleStatus.error);
      }
    } catch (e) {
      debugPrint('Load vehicles error: $e');
      _setError('Failed to load vehicles. Please try again.');
      _setStatus(VehicleStatus.error);
    }
  }

  // Load more vehicles (pagination)
  Future<void> loadMoreVehicles(String token) async {
    if (!_hasMoreData || _status == VehicleStatus.loading) return;

    await loadVehicles(token);
  }

  // Get single vehicle
  Future<Vehicle?> getVehicle(String token, String vehicleId) async {
    try {
      _setError(null);

      final response = await ApiService().getVehicle(vehicleId);

      if (response['vehicle'] != null) {
        return Vehicle.fromJson(response['vehicle']);
      } else {
        _setError(response['message'] ?? 'Failed to load vehicle');
        return null;
      }
    } catch (e) {
      debugPrint('Get vehicle error: $e');
      _setError('Failed to load vehicle. Please try again.');
      return null;
    }
  }

  // Create vehicle
  Future<bool> createVehicle(
    String token,
    Map<String, dynamic> vehicleData,
    List<XFile>? photos,
  ) async {
    try {
      _setError(null);

      final response = await ApiService().vehicleIn(
        vehicleData: vehicleData,
        photos: photos,
      );

      if (response['vehicle'] != null) {
        // Add the new vehicle to the beginning of the list
        final newVehicle = Vehicle.fromJson(response['vehicle']);
        _vehicles.insert(0, newVehicle);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to create vehicle');
        return false;
      }
    } catch (e) {
      debugPrint('Create vehicle error: $e');
      // Extract the actual error message from the exception
      String errorMessage = 'Failed to create vehicle. Please try again.';
      if (e is Exception) {
        String exceptionMessage = e.toString();
        if (exceptionMessage.startsWith('Exception: ')) {
          errorMessage = exceptionMessage.substring(
            11,
          ); // Remove "Exception: " prefix
        }
      }
      _setError(errorMessage);
      return false;
    }
  }

  // Update vehicle
  Future<bool> updateVehicle(
    String token,
    String vehicleId,
    Map<String, dynamic> vehicleData,
    List<XFile>? newPhotos,
  ) async {
    try {
      _setError(null);

      final response = await ApiService().updateVehicle(
        vehicleId,
        vehicleData,
        newPhotos: newPhotos,
      );

      if (response['vehicle'] != null) {
        // Update the vehicle in the list
        final updatedVehicle = Vehicle.fromJson(response['vehicle']);
        final index = _vehicles.indexWhere((v) => v.id == vehicleId);
        if (index != -1) {
          _vehicles[index] = updatedVehicle;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to update vehicle');
        return false;
      }
    } catch (e) {
      debugPrint('Update vehicle error: $e');
      // Extract the actual error message from the exception
      String errorMessage = 'Failed to update vehicle. Please try again.';
      if (e is Exception) {
        String exceptionMessage = e.toString();
        if (exceptionMessage.startsWith('Exception: ')) {
          errorMessage = exceptionMessage.substring(
            11,
          ); // Remove "Exception: " prefix
        }
      }
      _setError(errorMessage);
      return false;
    }
  }

  // Mark vehicle as out
  Future<bool> markVehicleOut(
    String token,
    String vehicleId,
    Map<String, dynamic> buyerData,
    XFile? buyerPhoto,
  ) async {
    try {
      _setError(null);
      debugPrint(
        'VehicleProvider: markVehicleOut called with vehicleId: $vehicleId',
      );

      final response = await ApiService().vehicleOut(
        vehicleId,
        buyerData,
        buyerPhoto: buyerPhoto,
      );

      debugPrint('VehicleProvider: markVehicleOut response: $response');

      if (response['vehicle'] != null) {
        // Update the vehicle in the list
        final updatedVehicle = Vehicle.fromJson(response['vehicle']);
        final index = _vehicles.indexWhere((v) => v.id == vehicleId);
        if (index != -1) {
          _vehicles[index] = updatedVehicle;
          notifyListeners();
        }
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to mark vehicle as out');
        return false;
      }
    } catch (e) {
      debugPrint('VehicleProvider: markVehicleOut error: $e');

      // Extract more specific error messages
      String errorMessage = 'Failed to mark vehicle as out. Please try again.';
      if (e is Exception) {
        String exceptionMessage = e.toString();
        if (exceptionMessage.startsWith('Exception: ')) {
          errorMessage = exceptionMessage.substring(
            11,
          ); // Remove "Exception: " prefix
        }
      }

      _setError(errorMessage);
      return false;
    }
  }

  // Delete vehicle
  Future<bool> deleteVehicle(String token, String vehicleId) async {
    try {
      _setError(null);

      final response = await ApiService().deleteVehicle(vehicleId);

      if (response['message'] != null) {
        // Remove the vehicle from the list
        _vehicles.removeWhere((v) => v.id == vehicleId);
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Failed to delete vehicle');
        return false;
      }
    } catch (e) {
      debugPrint('Delete vehicle error: $e');
      _setError('Failed to delete vehicle. Please try again.');
      return false;
    }
  }

  // Load dashboard statistics
  Future<void> loadDashboardStats(String token) async {
    try {
      _setError(null);

      final response = await ApiService().getDashboardStats();

      if (response['success'] == true) {
        _dashboardStats = DashboardStats.fromJson(response);
        notifyListeners();
      } else {
        _setError(response['message'] ?? 'Failed to load dashboard statistics');
      }
    } catch (e) {
      debugPrint('Load dashboard stats error: $e');
      _setError('Failed to load dashboard statistics. Please try again.');
    }
  }

  // Delete vehicle photo
  Future<bool> deleteVehiclePhoto(
    String token,
    String vehicleId,
    String photoId,
  ) async {
    try {
      _setError(null);

      // TODO: Implement deleteVehiclePhoto in ApiService
      // For now, return success without actual deletion
      return true;
    } catch (e) {
      debugPrint('Delete vehicle photo error: $e');
      _setError('Failed to delete photo. Please try again.');
      return false;
    }
  }

  // Search vehicles
  void searchVehicles(String token, String query) {
    _searchQuery = query;
    loadVehicles(
      token,
      refresh: true,
      search: query,
      status: _statusFilter,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  // Filter vehicles by status
  void filterByStatus(String token, String? status) {
    _statusFilter = status;
    loadVehicles(
      token,
      refresh: true,
      search: _searchQuery,
      status: status,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  // Filter vehicles by date range
  void filterByDateRange(String token, String? fromDate, String? toDate) {
    _fromDate = fromDate;
    _toDate = toDate;
    loadVehicles(
      token,
      refresh: true,
      search: _searchQuery,
      status: _statusFilter,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  // Clear all filters
  void clearFilters(String token) {
    _searchQuery = null;
    _statusFilter = null;
    _fromDate = null;
    _toDate = null;
    loadVehicles(token, refresh: true);
  }

  // Get vehicle counts
  int get totalVehicles => _vehicles.length;
  int get vehiclesIn => _vehicles.where((v) => v.status == 'in').length;
  int get vehiclesOut => _vehicles.where((v) => v.status == 'out').length;

  // Get vehicles by status
  List<Vehicle> getVehiclesByStatus(String status) {
    return _vehicles.where((v) => v.status == status).toList();
  }

  // Refresh data
  Future<void> refreshData(String token) async {
    await Future.wait([
      loadVehicles(token, refresh: true),
      loadDashboardStats(token),
    ]);
  }
}
