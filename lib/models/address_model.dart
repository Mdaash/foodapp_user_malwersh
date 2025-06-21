// lib/models/address_model.dart

// Simple address model for local use and compatibility
class AddressModel {
  final String id;
  final String name;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final bool isCurrent;
  final String type; // 'home', 'work', 'other', 'current'

  AddressModel({
    required this.id,
    required this.name,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.isCurrent = false,
    this.type = 'other',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
      'isCurrent': isCurrent,
      'type': type,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
      type: json['type'] ?? 'other',
    );
  }

  AddressModel copyWith({
    String? id,
    String? name,
    String? fullAddress,
    double? latitude,
    double? longitude,
    bool? isDefault,
    bool? isCurrent,
    String? type,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      isCurrent: isCurrent ?? this.isCurrent,
      type: type ?? this.type,
    );
  }
}

class AddressType {
  static const String home = 'home';
  static const String work = 'work';
  static const String other = 'other';
  static const String current = 'current';

  static const List<String> values = [home, work, other, current];

  static String getDisplayName(String type) {
    switch (type) {
      case home:
        return 'المنزل';
      case work:
        return 'العمل';
      case other:
        return 'أخرى';
      case current:
        return 'الموقع الحالي';
      default:
        return 'غير محدد';
    }
  }

  static String getIcon(String type) {
    switch (type) {
      case home:
        return '🏠';
      case work:
        return '🏢';
      case current:
        return '📍';
      case other:
      default:
        return '📌';
    }
  }
}

class DetailedAddress {
  final String id;
  final String userId;
  final String name;
  final String province;
  final String district;
  final String neighborhood;
  final String landmark;
  final String? detailedAddress;
  final String fullAddress;
  final double? latitude;
  final double? longitude;
  final String addressType;
  final bool isDefault;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  DetailedAddress({
    required this.id,
    required this.userId,
    required this.name,
    required this.province,
    required this.district,
    required this.neighborhood,
    required this.landmark,
    this.detailedAddress,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    required this.addressType,
    this.isDefault = false,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DetailedAddress.fromJson(Map<String, dynamic> json) {
    return DetailedAddress(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? 'عنوان غير محدد',
      province: json['province'] as String? ?? 'غير محدد',
      district: json['district'] as String? ?? 'غير محدد',
      neighborhood: json['neighborhood'] as String? ?? 'غير محدد',
      landmark: json['landmark'] as String? ?? 'غير محدد',
      detailedAddress: json['detailed_address'] as String?,
      fullAddress: json['full_address'] as String? ?? 'عنوان غير كامل',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      addressType: json['address_type'] as String? ?? AddressType.other,
      isDefault: json['is_default'] as bool? ?? false,
      buildingNumber: json['building_number'] as String?,
      floorNumber: json['floor_number'] as String?,
      apartmentNumber: json['apartment_number'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'province': province,
      'district': district,
      'neighborhood': neighborhood,
      'landmark': landmark,
      'detailed_address': detailedAddress,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'address_type': addressType,
      'is_default': isDefault,
      'building_number': buildingNumber,
      'floor_number': floorNumber,
      'apartment_number': apartmentNumber,
      'phone_number': phoneNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DetailedAddress copyWith({
    String? id,
    String? userId,
    String? name,
    String? province,
    String? district,
    String? neighborhood,
    String? landmark,
    String? detailedAddress,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? addressType,
    bool? isDefault,
    String? buildingNumber,
    String? floorNumber,
    String? apartmentNumber,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DetailedAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      province: province ?? this.province,
      district: district ?? this.district,
      neighborhood: neighborhood ?? this.neighborhood,
      landmark: landmark ?? this.landmark,
      detailedAddress: detailedAddress ?? this.detailedAddress,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      floorNumber: floorNumber ?? this.floorNumber,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName => AddressType.getDisplayName(addressType);
  String get typeIcon => AddressType.getIcon(addressType);
  
  String get shortAddress {
    List<String> parts = [];
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    if (district.isNotEmpty) parts.add(district);
    if (province.isNotEmpty) parts.add(province);
    return parts.take(2).join('، ');
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}

class AddressCreateRequest {
  final String name;
  final String province;
  final String district;
  final String neighborhood;
  final String landmark;
  final String? detailedAddress;
  final double? latitude;
  final double? longitude;
  final String addressType;
  final bool isDefault;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? phoneNumber;

  AddressCreateRequest({
    required this.name,
    required this.province,
    required this.district,
    required this.neighborhood,
    required this.landmark,
    this.detailedAddress,
    this.latitude,
    this.longitude,
    this.addressType = AddressType.other,
    this.isDefault = false,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'province': province,
      'district': district,
      'neighborhood': neighborhood,
      'landmark': landmark,
      'detailed_address': detailedAddress,
      'latitude': latitude,
      'longitude': longitude,
      'address_type': addressType,
      'is_default': isDefault,
      'building_number': buildingNumber,
      'floor_number': floorNumber,
      'apartment_number': apartmentNumber,
      'phone_number': phoneNumber,
    };
  }
}

class AddressUpdateRequest {
  final String? name;
  final String? province;
  final String? district;
  final String? neighborhood;
  final String? landmark;
  final String? detailedAddress;
  final double? latitude;
  final double? longitude;
  final String? addressType;
  final bool? isDefault;
  final String? buildingNumber;
  final String? floorNumber;
  final String? apartmentNumber;
  final String? phoneNumber;

  AddressUpdateRequest({
    this.name,
    this.province,
    this.district,
    this.neighborhood,
    this.landmark,
    this.detailedAddress,
    this.latitude,
    this.longitude,
    this.addressType,
    this.isDefault,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (province != null) data['province'] = province;
    if (district != null) data['district'] = district;
    if (neighborhood != null) data['neighborhood'] = neighborhood;
    if (landmark != null) data['landmark'] = landmark;
    if (detailedAddress != null) data['detailed_address'] = detailedAddress;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (addressType != null) data['address_type'] = addressType;
    if (isDefault != null) data['is_default'] = isDefault;
    if (buildingNumber != null) data['building_number'] = buildingNumber;
    if (floorNumber != null) data['floor_number'] = floorNumber;
    if (apartmentNumber != null) data['apartment_number'] = apartmentNumber;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    
    return data;
  }
}
