import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:inventrack_frontend/core/providers/user_provider.dart';
import 'package:inventrack_frontend/data/data_providers/product_api.dart';
import 'package:provider/provider.dart';
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
  String _selectedCategory = 'all';

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

    // Initially fetch all products
    _fetchProducts();
  }

  void _fetchProducts({String? category}) {
    setState(() {
      _products = (category == null || category == 'all'
              ? ProductApiService.getProductFeed()
              : ProductApiService.getProductsByCategory(category))
          .then((map) {
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

  void _onCategorySelected(String cat) {
    setState(() {
      _selectedCategory = cat;
      _searchController.clear();
      _searchQuery = '';
    });
    // Fetch products for the selected category
    _fetchProducts(category: cat == 'all' ? null : cat);
  }

  Widget _buildAnimatedSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimController,
      builder: (context, child) {
        return Container(
          width: _searchWidthAnimation.value,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

  List<String> get _categoryKeys => [
        'all',
        ...categoryDisplayNames.keys.where((k) => k != 'all' && k != 'other')
      ];

  @override
  void dispose() {
    _searchAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username ?? 'User';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/account');
          },
          child: Row(
            children: [
              const Text("Hi, "),
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          _buildAnimatedSearchBar(),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
          future: _products,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final products = _searchQuery.isEmpty
                ? (_filteredProducts.isNotEmpty
                    ? _filteredProducts
                    : snapshot.data ?? [])
                : _filteredProducts;

            if (products.isEmpty) {
              return const Center(child: Text("No products found."));
            }

            // Category chips
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    child: SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryKeys.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final cat = _categoryKeys[idx];
                          final label = cat == 'all'
                              ? 'All'
                              : (categoryDisplayNames[cat] ?? cat);
                          final selected = _selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) => _onCategorySelected(cat),
                            selectedColor: Colors.blueAccent,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    itemBuilder: (context, idx) {
                      final product = products[idx];
                      return _PinterestProductCard(product: product);
                    },
                    childCount: products.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PinterestProductCard extends StatelessWidget {
  final Product product;
  const _PinterestProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double cardWidth = (width - 48) / 2; // 2 columns, 16px spacing
    double imageHeight = cardWidth / 0.7; // Tall aspect ratio

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to product details or show dialog
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18), topRight: Radius.circular(18)),
              child: product.image.isNotEmpty
                  ? Image.network(
                      product.image,
                      width: cardWidth,
                      height: imageHeight * 0.55,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: cardWidth,
                        height: imageHeight * 0.55,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    )
                  : Container(
                      width: cardWidth,
                      height: imageHeight * 0.55,
                      color: Colors.grey[200],
                      child:
                          const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (product.category != null &&
                      categoryDisplayNames.containsKey(product.category))
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Chip(
                        label: Text(
                          categoryDisplayNames[product.category] ??
                              product.category,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: Colors.blue[50],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Price and Save button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        color: Colors.redAccent,
                        tooltip: 'Save',
                        onPressed: () {
                          // TODO: Implement save/favorite
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Map for display category names
const Map<String, String> categoryDisplayNames = {
  'all': 'All',
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
