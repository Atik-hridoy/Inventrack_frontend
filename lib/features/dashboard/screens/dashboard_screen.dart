import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventrack Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'logout',
            onPressed: () => _logout(context),
          ),
        ], // Center the title on app bar
      ),

      // Use a Center widget with SingleChildScrollView for responsiveness and overflow handling
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          // Limit max width for bigger screens (tablets, desktops)
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),

            // Use Column to arrange cards vertically
            child: Column(
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Stretch cards full width inside the constraint
              children: [
                // Welcome message with user name (placeholder)
                const Text(
                  "Welcome, Admin!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Dashboard summary cards in a Grid (2 columns)
                GridView(
                  shrinkWrap: true, // Prevents infinite height error
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, // Aspect ratio for cards
                  ),
                  children: const [
                    DashboardCard(
                      icon: Icons.inventory_2,
                      title: "Products",
                      count: 120,
                      color: Colors.blue,
                    ),
                    DashboardCard(
                      icon: Icons.shopping_cart,
                      title: "Sales Today",
                      count: 37,
                      color: Colors.green,
                    ),
                    DashboardCard(
                      icon: Icons.add_shopping_cart,
                      title: "Purchases",
                      count: 50,
                      color: Colors.orange,
                    ),
                    DashboardCard(
                      icon: Icons.store,
                      title: "Stock Items",
                      count: 87,
                      color: Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Placeholder for other dashboard content (charts, reports)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Reports & Analytics (Coming Soon)",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _logout(BuildContext context) {
  // Handle logout logic
  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
}

// Dashboard card widget to show summary info
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon on left with colored background circle
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),

            // Text info: title and count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 16)),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
