class DashboardStats {
  final int totalVehicles;
  final int vehiclesIn;
  final int vehiclesOut;
  final List<MonthlyData> monthlyData;

  DashboardStats({
    required this.totalVehicles,
    required this.vehiclesIn,
    required this.vehiclesOut,
    required this.monthlyData,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalVehicles: json['summary']['totalVehicles'] ?? 0,
      vehiclesIn: json['summary']['vehiclesIn'] ?? 0,
      vehiclesOut: json['summary']['vehiclesOut'] ?? 0,
      monthlyData:
          (json['monthlyData'] as List<dynamic>?)
              ?.map((data) => MonthlyData.fromJson(data))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'totalVehicles': totalVehicles,
        'vehiclesIn': vehiclesIn,
        'vehiclesOut': vehiclesOut,
      },
      'monthlyData': monthlyData.map((data) => data.toJson()).toList(),
    };
  }
}

class MonthlyData {
  final int month;
  final int vehiclesIn;
  final int vehiclesOut;

  MonthlyData({
    required this.month,
    required this.vehiclesIn,
    required this.vehiclesOut,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month'] ?? 0,
      vehiclesIn: json['vehiclesIn'] ?? 0,
      vehiclesOut: json['vehiclesOut'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'vehiclesIn': vehiclesIn,
      'vehiclesOut': vehiclesOut,
    };
  }

  String get monthName {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
