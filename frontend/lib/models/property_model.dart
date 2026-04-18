import 'user_model.dart';

class LocationModel {
  final String address;
  final String city;
  final String state;
  final String pincode;

  LocationModel({
    required this.address,
    required this.city,
    required this.state,
    this.pincode = '',
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    address: json['address'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    pincode: json['pincode'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'address': address,
    'city': city,
    'state': state,
    'pincode': pincode,
  };

  String get fullAddress => '$address, $city, $state${pincode.isNotEmpty ? ' - $pincode' : ''}';
  String get shortAddress => '$city, $state';
}

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final LocationModel location;
  final List<String> images;
  final String propertyType;
  final String furnishing;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> amenities;
  final bool isAvailable;
  final double deposit;
  final int views;
  final UserModel? owner;
  final String ownerId;
  final DateTime? createdAt;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    this.images = const [],
    this.propertyType = 'apartment',
    this.furnishing = 'unfurnished',
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.area = 0,
    this.amenities = const [],
    this.isAvailable = true,
    this.deposit = 0,
    this.views = 0,
    this.owner,
    this.ownerId = '',
    this.createdAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      location: LocationModel.fromJson(json['location'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
      propertyType: json['propertyType'] ?? 'apartment',
      furnishing: json['furnishing'] ?? 'unfurnished',
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      area: (json['area'] ?? 0).toDouble(),
      amenities: List<String>.from(json['amenities'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      deposit: (json['deposit'] ?? 0).toDouble(),
      views: json['views'] ?? 0,
      owner: json['ownerId'] is Map ? UserModel.fromJson(json['ownerId']) : null,
      ownerId: json['ownerId'] is String ? json['ownerId'] : (json['ownerId']?['_id'] ?? ''),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'price': price,
    'location': location.toJson(),
    'images': images,
    'propertyType': propertyType,
    'furnishing': furnishing,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'area': area,
    'amenities': amenities,
    'isAvailable': isAvailable,
    'deposit': deposit,
  };

  String get thumbnail => images.isNotEmpty ? images[0] : '';
  String get formattedPrice => '₹${price.toStringAsFixed(0)}/month';
  String get formattedDeposit => '₹${deposit.toStringAsFixed(0)}';
}
