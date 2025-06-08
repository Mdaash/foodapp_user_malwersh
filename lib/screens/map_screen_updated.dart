// lib/screens/map_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:foodapp_user/models/store.dart';
import 'package:foodapp_user/screens/store_detail_screen.dart';

// شبكة خريطة وهمية
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1.0;

    // رسم خطوط عمودية
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // رسم خطوط أفقية
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // رسم بعض الطرق الرئيسية
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0;

    // طريق أفقي رئيسي
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );

    // طريق عمودي رئيسي
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MapScreen extends StatefulWidget {
  final List<Store> stores;
  final Set<String> favoriteStoreIds;
  final Function(String) onToggleStoreFavorite;

  const MapScreen({
    super.key,
    required this.stores,
    required this.favoriteStoreIds,
    required this.onToggleStoreFavorite,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Store> _filteredStores = [];
  bool _showOpenOnly = false;
  String _searchQuery = '';
  // GoogleMapController? _mapController; // unused
  static const LatLng _userLocation = LatLng(24.7136, 46.6753); // موقع تقريبي (الرياض)
  final double _minRating = 1.0;
  final double _maxRating = 5.0;
  RangeValues _ratingRange = const RangeValues(1.0, 5.0);
  // bool _showRatingSheet = false; // unused
  late DraggableScrollableController _draggableController;
  bool _isSheetExpanded = false; // حالة تمدد الشيت

  @override
  void initState() {
    super.initState();
    _filteredStores = widget.stores;
    _draggableController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  void _filterStores() {
    setState(() {
      _filteredStores = widget.stores.where((store) {
        bool matchesSearch = _searchQuery.isEmpty ||
            store.name.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesOpenFilter = !_showOpenOnly || store.isOpen;
        double rating = double.tryParse(store.rating) ?? 0.0;
        bool matchesRatingFilter = rating >= _ratingRange.start && rating <= _ratingRange.end;
        return matchesSearch && matchesOpenFilter && matchesRatingFilter;
      }).toList();
    });
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('user'),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'موقعي'),
      ),
    };
    final double radius = 0.015;
    final int n = _filteredStores.length;
    for (int i = 0; i < n; i++) {
      final store = _filteredStores[i];
      final angle = (2 * 3.141592653 * i) / (n == 0 ? 1 : n);
      final lat = _userLocation.latitude + radius * math.sin(angle);
      final lng = _userLocation.longitude + radius * math.cos(angle);
      markers.add(
        Marker(
          markerId: MarkerId(store.id),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            store.isOpen ? BitmapDescriptor.hueRed : BitmapDescriptor.hueViolet,
          ),
          infoWindow: InfoWindow(
            title: store.name,
            snippet: store.isOpen ? 'مفتوح' : 'مغلق',
            onTap: () => _showStoreBottomSheet(store),
          ),
          onTap: () => _showStoreBottomSheet(store),
        ),
      );
    }
    return markers;
  }

  void _showRatingFilterSheet() async {
    RangeValues tempRange = _ratingRange;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double min = tempRange.start;
            double max = tempRange.end;
            int steps = 4;
            double step = ((max - min) / steps).clamp(0.1, 5.0);
            List<String> dynamicLabels = List.generate(
              steps + 1,
              (i) => (min + i * step).toStringAsFixed(1),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'التقييمات',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'من ${tempRange.start.toStringAsFixed(1)} إلى ${tempRange.end.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                  RangeSlider(
                    values: tempRange,
                    min: _minRating,
                    max: _maxRating,
                    divisions: 40,
                    activeColor: const Color(0xFF00c1e8), // لون الشريط الأساسي
                    inactiveColor: const Color(0x2200c1e8), // لون باهت للشريط
                    labels: RangeLabels(
                      tempRange.start.toStringAsFixed(1),
                      tempRange.end.toStringAsFixed(1),
                    ),
                    onChanged: (v) {
                      setModalState(() {
                        tempRange = v;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: dynamicLabels.map((e) => Text(e, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00c1e8), // اللون الأساسي
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        setState(() {
                          _ratingRange = tempRange;
                        });
                        Navigator.pop(context);
                        _filterStores();
                      },
                      child: const Text('عرض النتائج', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _ratingRange = const RangeValues(1.0, 5.0);
                      });
                      Navigator.pop(context);
                      _filterStores();
                    },
                    child: const Text(
                      'إعادة التعيين',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    // setState(() => _showRatingSheet = false);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _userLocation,
                zoom: 13,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _buildMarkers(),
              onMapCreated: (controller) {
                // _mapController = controller;
              },
              padding: const EdgeInsets.only(bottom: 220, top: 100),
            ),
            // الشريط العلوي
            _buildTopSection(),
            // القائمة السفلية
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    final bool isDefaultRating = _ratingRange.start == 1.0 && _ratingRange.end == 5.0;
    return SafeArea(
      child: Column(
        children: [
          // شريط البحث وزر الإغلاق
          Container(
            margin: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'البحث عن مطعم...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _filterStores();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // الفلاتر
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  'مفتوح الآن',
                  _showOpenOnly,
                  Icons.access_time,
                  () {
                    setState(() {
                      _showOpenOnly = !_showOpenOnly;
                    });
                    _filterStores();
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _showRatingFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: isDefaultRating ? Colors.black : Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        if (isDefaultRating)
                          const Text(
                            'حسب التقييم',
                            style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                          )
                        else
                          Text(
                            'من ${_ratingRange.start.toStringAsFixed(1)} إلى ${_ratingRange.end.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00c1e8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.15,
      maxChildSize: 0.7,
      controller: _draggableController,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المطاعم القريبة (${_filteredStores.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StatefulBuilder(
                      builder: (context, setStateSheetBtn) {
                        return IconButton(
                          onPressed: () {
                            if (!_isSheetExpanded) {
                              _draggableController.animateTo(
                                0.7,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _draggableController.animateTo(
                                0.22,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            }
                            setState(() {
                              _isSheetExpanded = !_isSheetExpanded;
                            });
                            setStateSheetBtn(() {});
                          },
                          icon: !_isSheetExpanded
                              ? const Icon(Icons.unfold_more, color: Color(0xFF00c1e8))
                              : const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00c1e8)),
                          tooltip: !_isSheetExpanded ? 'عرض الكل' : 'إغلاق القائمة',
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.vertical, // عمودي
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = _filteredStores[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildVerticalStoreCard(store),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalStoreCard(Store store) {
    return GestureDetector(
      onTap: () => _navigateToStoreDetail(store),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: Image.asset(
                store.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => widget.onToggleStoreFavorite(store.id),
                          child: Icon(
                            widget.favoriteStoreIds.contains(store.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: const Color(0xFF00c1e8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 15),
                        const SizedBox(width: 2),
                        Text(store.rating, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 10),
                        const Icon(Icons.access_time, size: 15, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(store.time, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: store.isOpen ? Colors.green : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            store.isOpen ? 'مفتوح' : 'مغلق',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // عرض المسافة دائماً
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 2),
                            Text(store.distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoreBottomSheet(Store store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            store.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(store.rating),
                                  const SizedBox(width: 8),
                                  Text('(${store.reviews})'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(store.time),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(store.distance),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToStoreDetail(store);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00c1e8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('عرض المطعم'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => widget.onToggleStoreFavorite(store.id),
                            icon: Icon(
                              widget.favoriteStoreIds.contains(store.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: const Color(0xFF00c1e8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStoreDetail(Store store) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailScreen(
          store: store,
          favoriteStoreIds: widget.favoriteStoreIds,
          onFavoriteToggle: (isFav) {
            if (isFav) {
              widget.favoriteStoreIds.add(store.id);
            } else {
              widget.favoriteStoreIds.remove(store.id);
            }
          },
        ),
      ),
    );
  }
}
