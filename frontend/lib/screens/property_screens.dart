import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../providers/property_provider.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

// ─── PROPERTY DETAILS ─────────────────────────────────────────────────────────
class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;
  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _imgIdx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().fetchProperty(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PropertyProvider>();
    final auth = context.watch<AuthProvider>();
    final property = prov.selectedProperty;

    if (prov.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (property == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Property not found')));
    }

    final isSaved = prov.isSaved(property.id);
    final isOwner = auth.user?.id == property.ownerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => prov.toggleSave(property.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? AppColors.primary : AppColors.textDark,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: property.images.isEmpty
                  ? Container(color: AppColors.softBeige, child: const Icon(Icons.home_rounded, size: 80, color: AppColors.border))
                  : Stack(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: double.infinity,
                            viewportFraction: 1.0,
                            onPageChanged: (i, _) => setState(() => _imgIdx = i),
                          ),
                          items: property.images.map((url) => Image.network(
                            url, fit: BoxFit.cover, width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.softBeige),
                          )).toList(),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 0, right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(property.images.length, (i) => Container(
                              width: i == _imgIdx ? 20 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _imgIdx ? AppColors.primary : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            )),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(property.title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(property.formattedPrice,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                          Text('Deposit: ${property.formattedDeposit}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 15, color: AppColors.textBody),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(property.location.fullAddress,
                            style: const TextStyle(fontSize: 13, color: AppColors.textBody)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _tag(_capitalize(property.furnishing), AppColors.primary),
                      _tag(_capitalize(property.propertyType), AppColors.trustHigh),
                      _tag('${property.bedrooms} BHK', AppColors.rating),
                      _tag('${property.area.toStringAsFixed(0)} sq.ft', AppColors.textBody),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Details row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _detail(Icons.bed_rounded, '${property.bedrooms}', 'Beds'),
                      _detail(Icons.bathtub_rounded, '${property.bathrooms}', 'Baths'),
                      _detail(Icons.square_foot_rounded, property.area.toStringAsFixed(0), 'sq.ft'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text(property.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
                  if (property.amenities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: property.amenities.map((a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.trustHigh.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.trustHigh.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.trustHigh),
                            const SizedBox(width: 4),
                            Text(a, style: const TextStyle(fontSize: 12, color: AppColors.trustHigh)),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                  if (property.owner != null) ...[
                    const SizedBox(height: 24),
                    const Text('About the Owner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          UserAvatar(user: property.owner!, radius: 26),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(property.owner!.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                const SizedBox(height: 2),
                                StarRatingDisplay(rating: property.owner!.averageRating, size: 13),
                                const SizedBox(height: 2),
                                Text('${property.owner!.totalReviews} reviews',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
                              ],
                            ),
                          ),
                          TrustScoreBadge(score: property.owner!.trustScore, size: 44, showLabel: false),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isOwner
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: property.owner == null ? null : () {
                        Navigator.pushNamed(
                          context,
                          '/messages/${property.owner!.id}',
                          arguments: {'name': property.owner!.name, 'partner': property.owner, 'propertyId': property.id},
                        );
                      },
                      icon: const Icon(Icons.chat_rounded, size: 18),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: property.owner == null ? null : () {
                        _showInquiryDialog(context, property.owner!.id, property.id);
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Inquire'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showInquiryDialog(BuildContext context, String ownerId, String propertyId) {
    final ctrl = TextEditingController(text: 'Hi, I am interested in your property. Is it still available?');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Inquiry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Your message'),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Send Inquiry',
              icon: Icons.send_rounded,
              onPressed: () async {
                Navigator.pop(context);
                final mp = context.read<MessageProvider>();
                await mp.sendMessage(
                  receiverId: ownerId,
                  content: ctrl.text,
                  propertyId: propertyId,
                  messageType: 'inquiry',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inquiry sent!'), backgroundColor: AppColors.trustHigh),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
  );

  Widget _detail(IconData icon, String value, String label) => Column(
    children: [
      Icon(icon, color: AppColors.primary, size: 22),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textDark)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textBody)),
    ],
  );

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── ADD / EDIT PROPERTY ──────────────────────────────────────────────────────
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _imagesCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();

  int _bedrooms = 1;
  int _bathrooms = 1;
  String _propertyType = 'apartment';
  String _furnishing = 'unfurnished';

  final List<String> _types = ['apartment', 'house', 'villa', 'studio', 'commercial'];
  final List<String> _furnishings = ['furnished', 'semi-furnished', 'unfurnished'];

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose();
    _depositCtrl.dispose(); _addressCtrl.dispose(); _cityCtrl.dispose();
    _stateCtrl.dispose(); _pincodeCtrl.dispose(); _areaCtrl.dispose();
    _imagesCtrl.dispose(); _amenitiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final images = _imagesCtrl.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
    final amenities = _amenitiesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text),
      'deposit': double.tryParse(_depositCtrl.text) ?? 0,
      'location': {
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'pincode': _pincodeCtrl.text.trim(),
      },
      'area': double.tryParse(_areaCtrl.text) ?? 0,
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'propertyType': _propertyType,
      'furnishing': _furnishing,
      'images': images.isNotEmpty ? images : [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800'
      ],
      'amenities': amenities,
    };

    final ok = await context.read<PropertyProvider>().createProperty(data);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property listed successfully!'), backgroundColor: AppColors.trustHigh),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<PropertyProvider>().error ?? 'Failed'), backgroundColor: AppColors.warning),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PropertyProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Basic Information'),
              _field(_titleCtrl, 'Property Title', required: true),
              const SizedBox(height: 14),
              _field(_descCtrl, 'Description', maxLines: 4, required: true),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _field(_priceCtrl, 'Monthly Rent (₹)', type: TextInputType.number, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_depositCtrl, 'Deposit (₹)', type: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              _section('Property Type'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _types.map((t) => ChoiceChip(
                  label: Text(_capitalize(t)),
                  selected: _propertyType == t,
                  onSelected: (_) => setState(() => _propertyType = t),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: _propertyType == t ? AppColors.primary : AppColors.textBody,
                    fontWeight: _propertyType == t ? FontWeight.w600 : FontWeight.normal,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              _section('Furnishing'),
              const SizedBox(height: 10),
              Row(
                children: _furnishings.map((f) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _furnishing = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _furnishing == f ? AppColors.primary.withOpacity(0.1) : AppColors.softBeige,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _furnishing == f ? AppColors.primary : AppColors.border),
                        ),
                        child: Text(
                          _capitalize(f.split('-').first),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _furnishing == f ? AppColors.primary : AppColors.textBody,
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              _section('Details'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _counter('Bedrooms', _bedrooms,
                      () => setState(() { if (_bedrooms > 0) _bedrooms--; }),
                      () => setState(() => _bedrooms++),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _counter('Bathrooms', _bathrooms,
                      () => setState(() { if (_bathrooms > 0) _bathrooms--; }),
                      () => setState(() => _bathrooms++),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_areaCtrl, 'Area (sq.ft)', type: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              _section('Location'),
              const SizedBox(height: 10),
              _field(_addressCtrl, 'Street Address', required: true),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _field(_cityCtrl, 'City', required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_stateCtrl, 'State', required: true)),
                ],
              ),
              const SizedBox(height: 14),
              _field(_pincodeCtrl, 'Pincode', type: TextInputType.number),
              const SizedBox(height: 20),
              _section('Images (URLs, one per line)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imagesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'https://...\nhttps://...',
                  labelText: 'Image URLs',
                ),
              ),
              const SizedBox(height: 14),
              _field(_amenitiesCtrl, 'Amenities (comma-separated)', hint: 'WiFi, AC, Parking, Gym'),
              const SizedBox(height: 28),
              PrimaryButton(label: 'List Property', onPressed: _submit, isLoading: prov.isLoading, icon: Icons.add_home_rounded),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
  );

  Widget _field(TextEditingController ctrl, String label, {
    int maxLines = 1, TextInputType? type, bool required = false, String? hint,
  }) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: type,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: required ? (v) => v == null || v.isEmpty ? '$label is required' : null : null,
  );

  Widget _counter(String label, int value, VoidCallback dec, VoidCallback inc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    decoration: BoxDecoration(color: AppColors.softBeige, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textBody)),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(onTap: dec, child: const Icon(Icons.remove_circle_outline_rounded, size: 18, color: AppColors.primary)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
            GestureDetector(onTap: inc, child: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.primary)),
          ],
        ),
      ],
    ),
  );

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
