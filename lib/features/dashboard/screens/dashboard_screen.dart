import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int newUsers = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNewUsers();
  }

  Future<void> fetchNewUsers() async {
    setState(() {
      isLoading = true;
    });
    // Replace with your actual API endpoint for users
    final result = await ApiService.get('accounts/list/');
    if (result['success'] == true && result['data'] != null) {
      final users = result['data'] is List
          ? result['data']
          : (result['data']['users'] ?? []);
      setState(() {
        newUsers = users.length;
        isLoading = false;
      });
    } else {
      setState(() {
        newUsers = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isWideScreen
                ? _buildWideLayout(context)
                : _buildNarrowLayout(context),
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildDashboardCard(
                context,
                title: 'Total Sales',
                value: '\$10,500',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildDashboardCard(
                context,
                title: 'New Users',
                value: isLoading ? 'Loading...' : '$newUsers',
                icon: Icons.person_add,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildChartPlaceholder(context, 'Sales Over Time'),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDashboardCard(
            context,
            title: 'Total Sales',
            value: '\$10,500',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'New Users',
            value: isLoading ? 'Loading...' : '$newUsers',
            icon: Icons.person_add,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Pending Orders',
            value: '25',
            icon: Icons.shopping_cart,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildChartPlaceholder(context, 'Sales Over Time'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-product');
            },
            child: const Text('Add Product'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/product-list');
            },
            child: const Text('Product List'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Placeholder for chart widget
  Widget _buildChartPlaceholder(BuildContext context, String title) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 200,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '$title (Chart goes here)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
