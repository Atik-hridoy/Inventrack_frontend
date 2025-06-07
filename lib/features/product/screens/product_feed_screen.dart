import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:inventrack_frontend/data/data_providers/product_api.dart';
import '../../../data/models/product.dart';

class ProductFeedScreen extends StatefulWidget {
  const ProductFeedScreen({super.key});

  @override
  State<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends State<ProductFeedScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Product>> _products;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  late AnimationController _searchAnimController;
  late Animation<double> _searchWidthAnimation;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _searchWidthAnimation =
        Tween<double>(begin: 48, end: 320).animate(CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeInOut,
    ));

    _products = ProductApiService.getProductFeed().then((map) {
      if (map['success'] == true && map['data'] != null) {
        final data = map['data'];
        List<dynamic> productList = [];
        if (data is List) {
          productList = data;
        } else if (data is Map && data['products'] is List) {
          productList = data['products'];
        }
        final products =
            productList.map((json) => Product.fromJson(json)).toList();
        _allProducts = products;
        _filteredProducts = products;
        return products;
      } else {
        throw Exception(map['error'] ?? 'Failed to load products');
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _allProducts
          .where((p) =>
              p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.description.toLowerCase().contains(query.toLowerCase()) ||
              p.sku.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildAnimatedSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimController,
      builder: (context, child) {
        return Container(
          width: _searchWidthAnimation.value,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showSearch ? Icons.close : Icons.search,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  setState(() {
                    _showSearch = !_showSearch;
                    if (_showSearch) {
                      _searchAnimController.forward();
                    } else {
                      _searchAnimController.reverse();
                      _searchController.clear();
                      _onSearchChanged('');
                    }
                  });
                },
              ),
              if (_searchWidthAnimation.value > 60)
                Expanded(
                  child: Opacity(
                    opacity: _showSearch ? 1 : 0,
                    child: TextField(
                      controller: _searchController,
                      autofocus: _showSearch,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Search products...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Helper to group products by category
  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final Map<String, List<Product>> grouped = {};
    for (final p in products) {
      final cat = (p.category ?? "other").toString().toLowerCase();
      final displayCat = categoryDisplayNames[cat] ?? 'Other';
      if (!grouped.containsKey(displayCat)) grouped[displayCat] = [];
      grouped[displayCat]!.add(p);
    }
    return grouped;
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Feed"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildAnimatedSearchBar(),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Blurry, colorful gradient background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB2FEFA),
                      Color(0xFF0ED2F7),
                      Color(0xFF8EC5FC),
                      Color(0xFFE0C3FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<List<Product>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // Use filtered products if searching, else all
                final products = _searchQuery.isEmpty
                    ? (_allProducts.isNotEmpty
                        ? _allProducts
                        : snapshot.data ?? [])
                    : _filteredProducts;

                if (products.isEmpty) {
                  return const Center(child: Text("No products found."));
                }

                // Group by category
                final grouped = _groupByCategory(products);

                return ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: grouped.entries.map((entry) {
                    final category = entry.key;
                    final items = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          child: Text(
                            // Capitalize category for display
                            category[0].toUpperCase() + category.substring(1),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 260,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, idx) =>
                                _ProductCard(product: items[idx]),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Responsive sizing
    final width = MediaQuery.of(context).size.width;
    double cardWidth;
    double imageRadius;
    double padding;
    double fontSizeTitle;
    double fontSizeDesc;

    if (width > 1200) {
      cardWidth = 260;
      imageRadius = 48;
      padding = 18;
      fontSizeTitle = 18;
      fontSizeDesc = 14;
    } else if (width > 900) {
      cardWidth = 220;
      imageRadius = 42;
      padding = 16;
      fontSizeTitle = 17;
      fontSizeDesc = 13;
    } else if (width > 600) {
      cardWidth = 180;
      imageRadius = 36;
      padding = 14;
      fontSizeTitle = 16;
      fontSizeDesc = 12;
    } else {
      cardWidth = 150;
      imageRadius = 32;
      padding = 10;
      fontSizeTitle = 15;
      fontSizeDesc = 11;
    }

    return Center(
      child: Card(
        elevation: 7,
        color: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: cardWidth,
          padding:
              EdgeInsets.symmetric(horizontal: padding, vertical: padding + 8),
          child: Column(
            mainAxisSize: MainAxisSize.min, // <-- This line is important!
            children: [
              // Circle product image at top
              CircleAvatar(
                radius: imageRadius,
                backgroundColor: Colors.grey[200],
                backgroundImage: product.image.isNotEmpty
                    ? NetworkImage(product.image)
                    : null,
                child: product.image.isEmpty
                    ? Icon(Icons.image, size: imageRadius, color: Colors.grey)
                    : null,
              ),
              SizedBox(height: padding),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeTitle,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (product.description.isNotEmpty) ...[
                SizedBox(height: 6),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSizeDesc,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (product.sku.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  'SKU: ${product.sku}',
                  style: TextStyle(
                    fontSize: fontSizeDesc - 1,
                    color: Colors.blueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: fontSizeTitle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Qty: ${product.quantity}',
                    style: TextStyle(
                      fontSize: fontSizeDesc,
                      color: Colors.deepOrange,
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
}

// Map for display category names
const Map<String, String> categoryDisplayNames = {
  'electronics': 'Electronics',
  'clothing': 'Clothing',
  'home': 'Home',
  'toys': 'Toys',
  'books': 'Books',
  'sports': 'Sports',
  'automotive': 'Automotive',
  'health': 'Health',
  'beauty': 'Beauty',
  'garden': 'Garden',
  'computers': 'Computers',
  'jewelry': 'Jewelry',
  'musical_instruments': 'Musical Instruments',
  'office_products': 'Office Products',
  'pet_supplies': 'Pet Supplies',
  'tools': 'Tools',
  'video_games': 'Video Games',
  'baby': 'Baby',
  'groceries': 'Groceries',
  'furniture': 'Furniture',
  'appliances': 'Appliances',
  'clothing_shoes': 'Clothing & Shoes',
  'bags': 'Bags',
  'accessories': 'Accessories',
  'watches': 'Watches',
  'phones': 'Phones',
  'tablets': 'Tablets',
  'cameras': 'Cameras',
  'drones': 'Drones',
  'projectors': 'Projectors',
  'monitors': 'Monitors',
  'printers': 'Printers',
  'scanners': 'Scanners',
  'speakers': 'Speakers',
  'headphones': 'Headphones',
  'microphones': 'Microphones',
  'mixers': 'Mixers',
  'turntables': 'Turntables',
  'synthesizers': 'Synthesizers',
  'keyboards': 'Keyboards',
  'guitars': 'Guitars',
  'drums': 'Drums',
  'violins': 'Violins',
  'trumpets': 'Trumpets',
  'saxophones': 'Saxophones',
  'flutes': 'Flutes',
  'clarinets': 'Clarinets',
  'trombones': 'Trombones',
  'harps': 'Harps',
  'accordions': 'Accordions',
  'ukuleles': 'Ukuleles',
  'banjos': 'Banjos',
  'mandolins': 'Mandolins',
  'harmonicas': 'Harmonicas',
  'recorders': 'Recorders',
  'castanets': 'Castanets',
  'maracas': 'Maracas',
  'tambourines': 'Tambourines',
  'triangles': 'Triangles',
  'cymbals': 'Cymbals',
  'gong': 'Gong',
  'bells': 'Bells',
  'whistles': 'Whistles',
  'kazoos': 'Kazoos',
  'vuvuzelas': 'Vuvuzelas',
  'didgeridoos': 'Didgeridoos',
  'bagpipes': 'Bagpipes',
  'pan_flutes': 'Pan Flutes',
  'steel_drums': 'Steel Drums',
  'bongos': 'Bongos',
  'congas': 'Conga',
  'other': 'Other',
};
