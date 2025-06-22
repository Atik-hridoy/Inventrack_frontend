import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import 'edit_profile_screen.dart'; // Import the EditProfileScreen

class UserAccountScreen extends StatelessWidget {
  const UserAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? 'User';
    final email = userProvider.email ?? 'No email';
    final staffName = userProvider.staffName ?? '';
    final nickname = userProvider.nickname ?? '';
    final phone = userProvider.phone ?? '';
    final street = userProvider.street ?? '';
    final house = userProvider.house ?? '';
    final district = userProvider.district ?? '';
    String address = '';
    if (street.isNotEmpty || house.isNotEmpty || district.isNotEmpty) {
      address = [street, house, district].where((e) => e.isNotEmpty).join(', ');
    }
    final userId = userProvider.userId ?? '';

    final mainDisplayName = nickname.isNotEmpty ? nickname : username;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF263238)),
              tooltip: 'Back to Feed',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/product-feed');
              },
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF1976D2)),
              tooltip: 'Open Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ],
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: Color(0xFF263238),
            fontWeight: FontWeight.w700,
            fontSize: 21,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              if (updated == true) {
                // Optionally refresh user info from backend/provider
              }
            },
          ),
        ],
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF212B36),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF263238),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF1976D2),
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFB0BEC5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _DrawerTile(
                icon: Icons.shopping_bag_outlined,
                title: 'Order History',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/order-history');
                },
                color: Colors.white,
              ),
              _DrawerTile(
                icon: Icons.favorite_border,
                title: 'Wishlist',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/wishlist');
                },
                color: Colors.white,
              ),
              _DrawerTile(
                icon: Icons.location_on_outlined,
                title: 'Addresses',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/addresses');
                },
                color: Colors.white,
              ),
              _DrawerTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/payment-methods');
                },
                color: Colors.white,
              ),
              _DrawerTile(
                icon: Icons.settings_outlined,
                title: 'Settings & Security',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
          child: Material(
            elevation: 2,
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF1976D2),
                        child: Text(
                          mainDisplayName.isNotEmpty
                              ? mainDisplayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainDisplayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF263238),
                              ),
                            ),
                            if (staffName.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  staffName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF1976D2),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Color(0xFFE0E0E0), thickness: 1),
                  const SizedBox(height: 18),
                  if (phone.isNotEmpty)
                    _InfoRow(
                        label: 'Phone',
                        value: phone,
                        icon: Icons.phone_outlined),
                  if (address.isNotEmpty)
                    _InfoRow(
                        label: 'Address',
                        value: address,
                        icon: Icons.home_outlined),
                  _InfoRow(
                      label: 'Email', value: email, icon: Icons.email_outlined),
                  _InfoRow(
                      label: 'User ID',
                      value: userId.toString(),
                      icon: Icons.badge_outlined),
                  const SizedBox(height: 32),
                  Divider(color: Color(0xFFE0E0E0), thickness: 1),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF263238),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Optionally clear user session/provider here
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1976D2), size: 22),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF263238),
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  const _DrawerTile(
      {required this.icon,
      required this.title,
      required this.onTap,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: color,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 16, color: color.withOpacity(0.7)),
      onTap: onTap,
    );
  }
}
