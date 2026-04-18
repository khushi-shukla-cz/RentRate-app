import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../services/services.dart';

class PropertyProvider extends ChangeNotifier {
  List<PropertyModel> _properties = [];
  List<PropertyModel> _myProperties = [];
  List<PropertyModel> _savedProperties = [];
  PropertyModel? _selectedProperty;
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  int _total = 0;
  bool _hasMore = true;

  // Filters
  String _filterCity = '';
  String _filterFurnishing = '';
  String _filterType = '';
  double? _filterMinPrice;
  double? _filterMaxPrice;

  List<PropertyModel> get properties => _properties;
  List<PropertyModel> get myProperties => _myProperties;
  List<PropertyModel> get savedProperties => _savedProperties;
  PropertyModel? get selectedProperty => _selectedProperty;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get total => _total;

  void setFilters({
    String city = '', String furnishing = '', String type = '',
    double? minPrice, double? maxPrice,
  }) {
    _filterCity = city;
    _filterFurnishing = furnishing;
    _filterType = type;
    _filterMinPrice = minPrice;
    _filterMaxPrice = maxPrice;
    fetchProperties(reset: true);
  }

  Future<void> fetchProperties({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      _properties = [];
    }
    if (!_hasMore || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final res = await PropertyService.getProperties(
      city: _filterCity, furnishing: _filterFurnishing,
      propertyType: _filterType, minPrice: _filterMinPrice,
      maxPrice: _filterMaxPrice, page: _page,
    );

    _isLoading = false;
    if (res['success'] == true) {
      final list = (res['properties'] as List).map((e) => PropertyModel.fromJson(e)).toList();
      _total = res['total'] ?? 0;
      if (reset) {
        _properties = list;
      } else {
        _properties.addAll(list);
      }
      _hasMore = _properties.length < _total;
      _page++;
    } else {
      _error = res['message'] ?? 'Failed to fetch properties';
    }
    notifyListeners();
  }

  Future<void> fetchProperty(String id) async {
    _isLoading = true;
    _selectedProperty = null;
    notifyListeners();
    final res = await PropertyService.getProperty(id);
    _isLoading = false;
    if (res['success'] == true) {
      _selectedProperty = PropertyModel.fromJson(res['property']);
    } else {
      _error = res['message'];
    }
    notifyListeners();
  }

  Future<void> fetchMyProperties() async {
    _isLoading = true;
    notifyListeners();
    final res = await PropertyService.getMyProperties();
    _isLoading = false;
    if (res['success'] == true) {
      _myProperties = (res['properties'] as List).map((e) => PropertyModel.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> fetchSavedProperties() async {
    final res = await PropertyService.getSavedProperties();
    if (res['success'] == true) {
      _savedProperties = (res['properties'] as List).map((e) => PropertyModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<bool> createProperty(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final res = await PropertyService.createProperty(data);
    _isLoading = false;
    if (res['success'] == true) {
      await fetchMyProperties();
      notifyListeners();
      return true;
    }
    _error = res['message'];
    notifyListeners();
    return false;
  }

  Future<bool> deleteProperty(String id) async {
    final res = await PropertyService.deleteProperty(id);
    if (res['success'] == true) {
      _myProperties.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> toggleSave(String id) async {
    final res = await PropertyService.toggleSave(id);
    if (res['success'] == true) {
      await fetchSavedProperties();
      return true;
    }
    return false;
  }

  bool isSaved(String id) => _savedProperties.any((p) => p.id == id);
}
