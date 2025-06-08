import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int newUsers = 0;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _userCountAnimation;

  @override
  void initState() {
    super.initState();
    fetchNewUsers();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _userCountAnimation =
        Tween<double>(begin: 0, end: newUsers.toDouble()).animate(_controller);

    // Fetch user info from backend if staffName is not set
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final email = userProvider.email;
      if ((userProvider.staffName == null || userProvider.staffName!.isEmpty) &&
          email != null &&
          email.isNotEmpty) {
        await userProvider.fetchAndSetUserInfo(email: email);
      }
    });
  }

  Future<void> fetchNewUsers() async {
    setState(() {
      isLoading = true;
    });
    final result = await ApiService.get('accounts/list/');
    if (result['success'] == true && result['data'] != null) {
      final users = result['data'] is List
          ? result['data']
          : (result['data']['users'] ?? []);
      setState(() {
        newUsers = users.length;
        isLoading = false;
        _userCountAnimation = Tween<double>(begin: 0, end: newUsers.toDouble())
            .animate(_controller);
        _controller.forward(from: 0);
      });
    } else {
      setState(() {
        newUsers = 0;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildGradientCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    double? width,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        title: Text(
          title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedUserCard(double width) {
    return AnimatedBuilder(
      animation: _userCountAnimation,
      builder: (context, child) {
        return _buildGradientCard(
          title: 'New Users',
          value: isLoading
              ? 'Loading...'
              : _userCountAnimation.value.toInt().toString(),
          icon: Icons.person_add,
          gradientColors: [Colors.blue, Colors.blueAccent],
          width: width,
        );
      },
    );
  }

  Widget _buildSimpleBarChart(double width) {
    final data = [80, 120, 60, 150, 100, 90, 130];
    final max = data.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: width,
        height: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Sales Over Time',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((value) {
                  final barHeight = (value / max) * 100;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: barHeight + 20,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffName = Provider.of<UserProvider>(context).staffName ?? '';
    final email = Provider.of<UserProvider>(context).email ?? '';

    print('DEBUG: email = $email');
    print('DEBUG: staffName = $staffName');

    final media = MediaQuery.of(context);
    final width = media.size.width < 500 ? media.size.width * 0.95 : 400.0;
    final titleFont = media.size.width < 500 ? 20.0 : 24.0;
    final welcomeFont = media.size.width < 500 ? 22.0 : 28.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Optionally clear user session/provider here
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Blurry gradient background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          // Main content
          LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          staffName.isNotEmpty
                              ? 'Welcome Back, $staffName!'
                              : 'Welcome Back!',
                          style: TextStyle(
                            fontSize: welcomeFont,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Here’s what’s happening with your store today.',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Overview', titleFont),
                        _buildGradientCard(
                          title: 'Total Sales',
                          value: '\$10,500',
                          icon: Icons.attach_money,
                          gradientColors: [Colors.green, Colors.teal],
                          width: width,
                        ),
                        _buildAnimatedUserCard(width),
                        _buildGradientCard(
                          title: 'Pending Orders',
                          value: '25',
                          icon: Icons.shopping_cart,
                          gradientColors: [
                            Colors.orange,
                            Colors.deepOrangeAccent
                          ],
                          width: width,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Analytics', titleFont),
                        _buildSimpleBarChart(width),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add-product');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Product'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/product-list');
                                },
                                icon: const Icon(Icons.list),
                                label: const Text('Product List'),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                      color: Colors.blueAccent, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
