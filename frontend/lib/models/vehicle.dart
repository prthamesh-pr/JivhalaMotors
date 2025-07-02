class VehiclePhoto {
  final String filename;
  final String originalName;
  final String path;
  final DateTime uploadDate;
  final String? url;

  VehiclePhoto({
    required this.filename,
    required this.originalName,
    required this.path,
    required this.uploadDate,
    this.url,
  });

  factory VehiclePhoto.fromJson(Map<String, dynamic> json) {
    return VehiclePhoto(
      filename: json['filename'] ?? '',
      originalName: json['originalName'] ?? '',
      path: json['path'] ?? '',
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : DateTime.now(),
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'originalName': originalName,
      'path': path,
      'uploadDate': uploadDate.toIso8601String(),
      'url': url,
    };
  }
}

class VehicleDocuments {
  final bool rc;
  final bool puc;
  final bool noc;

  VehicleDocuments({required this.rc, required this.puc, required this.noc});

  factory VehicleDocuments.fromJson(Map<String, dynamic> json) {
    return VehicleDocuments(
      rc: json['RC'] ?? false,
      puc: json['PUC'] ?? false,
      noc: json['NOC'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'RC': rc, 'PUC': puc, 'NOC': noc};
  }
}

class Buyer {
  final String? buyerName;
  final String? address;
  final String? mobileNo;
  final double? price;
  final double? rtoCharges;
  final double? commission;
  final double? token;
  final double? receivedPrice;
  final double? balance;
  final String? aadharCard;
  final String? panCard;
  final String? dlNumber;
  final String? idProofType;
  final VehiclePhoto? buyerPhoto;

  Buyer({
    this.buyerName,
    this.address,
    this.mobileNo,
    this.price,
    this.rtoCharges,
    this.commission,
    this.token,
    this.receivedPrice,
    this.balance,
    this.aadharCard,
    this.panCard,
    this.dlNumber,
    this.idProofType,
    this.buyerPhoto,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      buyerName: json['buyerName'],
      address: json['address'],
      mobileNo: json['mobileNo'],
      price: json['price']?.toDouble(),
      rtoCharges: json['rtoCharges']?.toDouble(),
      commission: json['commission']?.toDouble(),
      token: json['token']?.toDouble(),
      receivedPrice: json['receivedPrice']?.toDouble(),
      balance: json['balance']?.toDouble(),
      aadharCard: json['aadharCard'],
      panCard: json['panCard'],
      dlNumber: json['dlNumber'],
      idProofType: json['idProofType'],
      buyerPhoto: json['buyerPhoto'] != null
          ? VehiclePhoto.fromJson(json['buyerPhoto'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buyerName': buyerName,
      'address': address,
      'mobileNo': mobileNo,
      'price': price,
      'rtoCharges': rtoCharges,
      'commission': commission,
      'token': token,
      'receivedPrice': receivedPrice,
      'balance': balance,
      'aadharCard': aadharCard,
      'panCard': panCard,
      'dlNumber': dlNumber,
      'idProofType': idProofType,
      'buyerPhoto': buyerPhoto?.toJson(),
    };
  }
}

class Vehicle {
  final String id;
  final String uniqueId;
  final DateTime vehicleInDate;
  final String vehicleNumber;
  final String? vehicleHP;
  final String chassisNo;
  final String engineNo;
  final String vehicleName;
  final int modelYear;
  final String ownerName;
  final String ownerType;
  final String mobileNo;
  final DateTime? insuranceDate;
  final String? challan;
  final VehicleDocuments documents;
  final List<VehiclePhoto> photos;
  final String status;
  final DateTime? outDate;
  final Buyer? buyer;
  final String createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.uniqueId,
    required this.vehicleInDate,
    required this.vehicleNumber,
    this.vehicleHP,
    required this.chassisNo,
    required this.engineNo,
    required this.vehicleName,
    required this.modelYear,
    required this.ownerName,
    required this.ownerType,
    required this.mobileNo,
    this.insuranceDate,
    this.challan,
    required this.documents,
    required this.photos,
    required this.status,
    this.outDate,
    this.buyer,
    required this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? json['id'] ?? '',
      uniqueId: json['uniqueId'] ?? '',
      vehicleInDate: DateTime.parse(json['vehicleInDate']),
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleHP: json['vehicleHP'],
      chassisNo: json['chassisNo'] ?? '',
      engineNo: json['engineNo'] ?? '',
      vehicleName: json['vehicleName'] ?? '',
      modelYear: json['modelYear'] ?? DateTime.now().year,
      ownerName: json['ownerName'] ?? '',
      ownerType: json['ownerType'] ?? '1st',
      mobileNo: json['mobileNo'] ?? '',
      insuranceDate: json['insuranceDate'] != null
          ? DateTime.parse(json['insuranceDate'])
          : null,
      challan: json['challan'],
      documents: VehicleDocuments.fromJson(json['documents'] ?? {}),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((photo) => VehiclePhoto.fromJson(photo))
              .toList() ??
          [],
      status: json['status'] ?? 'in',
      outDate: json['outDate'] != null ? DateTime.parse(json['outDate']) : null,
      buyer: json['buyer'] != null ? Buyer.fromJson(json['buyer']) : null,
      createdBy: _extractUserName(json['createdBy']),
      updatedBy: _extractUserName(json['updatedBy']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Helper method to extract user name from either string or object
  static String _extractUserName(dynamic userData) {
    if (userData == null) return '';
    if (userData is String) return userData;
    if (userData is Map<String, dynamic>) {
      return userData['name'] ?? userData['username'] ?? userData['_id'] ?? '';
    }
    return userData.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'uniqueId': uniqueId,
      'vehicleInDate': vehicleInDate.toIso8601String(),
      'vehicleNumber': vehicleNumber,
      'vehicleHP': vehicleHP,
      'chassisNo': chassisNo,
      'engineNo': engineNo,
      'vehicleName': vehicleName,
      'modelYear': modelYear,
      'ownerName': ownerName,
      'ownerType': ownerType,
      'mobileNo': mobileNo,
      'insuranceDate': insuranceDate?.toIso8601String(),
      'challan': challan,
      'documents': documents.toJson(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
      'status': status,
      'outDate': outDate?.toIso8601String(),
      'buyer': buyer?.toJson(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? uniqueId,
    DateTime? vehicleInDate,
    String? vehicleNumber,
    String? vehicleHP,
    String? chassisNo,
    String? engineNo,
    String? vehicleName,
    int? modelYear,
    String? ownerName,
    String? ownerType,
    String? mobileNo,
    DateTime? insuranceDate,
    String? challan,
    VehicleDocuments? documents,
    List<VehiclePhoto>? photos,
    String? status,
    DateTime? outDate,
    Buyer? buyer,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      vehicleInDate: vehicleInDate ?? this.vehicleInDate,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleHP: vehicleHP ?? this.vehicleHP,
      chassisNo: chassisNo ?? this.chassisNo,
      engineNo: engineNo ?? this.engineNo,
      vehicleName: vehicleName ?? this.vehicleName,
      modelYear: modelYear ?? this.modelYear,
      ownerName: ownerName ?? this.ownerName,
      ownerType: ownerType ?? this.ownerType,
      mobileNo: mobileNo ?? this.mobileNo,
      insuranceDate: insuranceDate ?? this.insuranceDate,
      challan: challan ?? this.challan,
      documents: documents ?? this.documents,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      outDate: outDate ?? this.outDate,
      buyer: buyer ?? this.buyer,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOut => status == 'out';
  bool get isIn => status == 'in';

  @override
  String toString() {
    return 'Vehicle(id: $id, vehicleNumber: $vehicleNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
