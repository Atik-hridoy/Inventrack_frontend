import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../../../core/services/api_service.dart' as core_api;
import '../../../data/data_providers/product_api.dart';
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
  List<Map<String, dynamic>> products = [];
  bool isProductLoading = true;
  late AnimationController _controller;
  late Animation<double> _userCountAnimation;

  @override
  void initState() {
    super.initState();
    fetchNewUsers();
    fetchProducts();
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
    final result = await core_api.ApiService.get('accounts/list/');
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

  Future<void> fetchProducts() async {
    setState(() {
      isProductLoading = true;
    });
    final result = await ProductApiService.getProductFeed();
    if (result['success'] == true && result['data'] != null) {
      final items = result['data'] is List
          ? result['data']
          : (result['data']['results'] ??
              result['data']['products'] ??
              result['data']);
      setState(() {
        products = List<Map<String, dynamic>>.from(items);
        isProductLoading = false;
      });
    } else {
      setState(() {
        products = [];
        isProductLoading = false;
      });
    }
  }

  Widget _buildProductTable() {
    if (isProductLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No products found.')),
      );
    }
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
                label: Text('Product Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label:
                    Text('SKU', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Stock',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Price',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: products.map((product) {
            return DataRow(cells: [
              DataCell(Text(product['name']?.toString() ?? '-')),
              DataCell(Text(product['sku']?.toString() ?? '-')),
              DataCell(Text(product['stock']?.toString() ?? '-')),
              DataCell(Text(product['price']?.toString() ?? '-')),
            ]);
          }).toList(),
        ),
      ),
    );
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
    final media = MediaQuery.of(context);
    final width = media.size.width < 900
        ? media.size.width * 0.98
        : media.size.width < 1200
            ? 700.0
            : 900.0;
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
                        _buildAnimatedUserCard(width),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Inventory', titleFont),
                        InventoryTable(
                            products: products, isLoading: isProductLoading),
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

class InventoryTable extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final bool isLoading;
  const InventoryTable(
      {required this.products, required this.isLoading, super.key});

  @override
  State<InventoryTable> createState() => _InventoryTableState();
}

class _InventoryTableState extends State<InventoryTable> {
  String _search = '';
  int? _hoveredRow;
  String _sortColumn = 'name';
  bool _sortAsc = true;
  Set<int> _selectedRows = {};
  int? _editingRow;
  String? _editingField;
  String? _editingValue;

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> list = widget.products;
    if (_search.isNotEmpty) {
      list = list.where((p) {
        return (p['name']?.toString().toLowerCase() ?? '')
                .contains(_search.toLowerCase()) ||
            (p['sku']?.toString().toLowerCase() ?? '')
                .contains(_search.toLowerCase());
      }).toList();
    }
    list.sort((a, b) {
      final aVal = a[_sortColumn];
      final bVal = b[_sortColumn];
      int cmp;
      if (aVal is num && bVal is num) {
        cmp = aVal.compareTo(bVal);
      } else {
        cmp = aVal.toString().compareTo(bVal.toString());
      }
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  void _onSort(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAsc = !_sortAsc;
      } else {
        _sortColumn = column;
        _sortAsc = true;
      }
    });
  }

  void _onEdit(int row, String field, String value) {
    setState(() {
      _editingRow = row;
      _editingField = field;
      _editingValue = value;
    });
  }

  void _onEditSubmit(int row, String field) {
    setState(() {
      if (_editingValue != null) {
        widget.products[row][field] = _editingValue;
        // TODO: Call backend to update value
      }
      _editingRow = null;
      _editingField = null;
      _editingValue = null;
    });
  }

  void _onSelectRow(int row, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows.add(row);
      } else {
        _selectedRows.remove(row);
      }
    });
  }

  void _onSelectAll(bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows =
            Set.from(List.generate(filteredProducts.length, (i) => i));
      } else {
        _selectedRows.clear();
      }
    });
  }

  void _onDeleteSelected() {
    setState(() {
      final toDelete = _selectedRows.toList()..sort((a, b) => b.compareTo(a));
      for (final i in toDelete) {
        widget.products.removeAt(i);
        // TODO: Call backend to delete
      }
      _selectedRows.clear();
    });
  }

  void _onExportCSV() {
    final headers = ['Product Name', 'SKU', 'Stock', 'Price'];
    final rows = filteredProducts
        .map((p) => [
              p['name']?.toString() ?? '',
              p['sku']?.toString() ?? '',
              p['stock']?.toString() ?? '',
              p['price']?.toString() ?? '',
            ])
        .toList();
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(row.map((e) => '"$e"').join(','));
    }
    final blob = html.Blob([csv.toString()], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'products.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 600;
    final tableWidth = media.size.width < 900
        ? media.size.width * 0.98
        : media.size.width * 0.85;
    final tableHeight = isMobile ? 220.0 : 540.0;
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No products found.')),
      );
    }
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(top: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: tableWidth,
          height: tableHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name or SKU...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed:
                          _selectedRows.isNotEmpty ? _onDeleteSelected : null,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Selected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _onExportCSV,
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(fontSize: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(
                            color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Sticky Table header
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFe3f2fd),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectedRows.length == filteredProducts.length &&
                          filteredProducts.isNotEmpty,
                      onChanged: (val) => _onSelectAll(val),
                    ),
                    _ExcelHeaderCellSortable(
                        'Product Name', 'name', _sortColumn, _sortAsc,
                        onTap: _onSort, flex: 3),
                    _ExcelHeaderCellSortable(
                        'SKU', 'sku', _sortColumn, _sortAsc,
                        onTap: _onSort, flex: 2),
                    _ExcelHeaderCellSortable(
                        'Stock', 'stock', _sortColumn, _sortAsc,
                        onTap: _onSort, flex: 2),
                    _ExcelHeaderCellSortable(
                        'Price', 'price', _sortColumn, _sortAsc,
                        onTap: _onSort, flex: 2),
                    _ExcelHeaderCell('Actions', flex: 2),
                  ],
                ),
              ),
              // Table body
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isEven = index % 2 == 0;
                      final selected = _selectedRows.contains(index);
                      return MouseRegion(
                        onEnter: (_) => setState(() => _hoveredRow = index),
                        onExit: (_) => setState(() => _hoveredRow = null),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.blue.withOpacity(0.13)
                                : _hoveredRow == index
                                    ? Colors.blue.withOpacity(0.07)
                                    : isEven
                                        ? Colors.white
                                        : const Color(0xFFF7FAFC),
                            border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: selected,
                                onChanged: (val) => _onSelectRow(index, val),
                              ),
                              _ExcelCellEditable(
                                value: product['name']?.toString() ?? '-',
                                flex: 3,
                                editing: _editingRow == index &&
                                    _editingField == 'name',
                                onDoubleTap: () => _onEdit(index, 'name',
                                    product['name']?.toString() ?? ''),
                                onChanged: (v) =>
                                    setState(() => _editingValue = v),
                                onSubmitted: () => _onEditSubmit(index, 'name'),
                                monospace: false,
                                editingValue: _editingRow == index &&
                                        _editingField == 'name'
                                    ? _editingValue
                                    : null,
                              ),
                              _ExcelCellEditable(
                                value: product['sku']?.toString() ?? '-',
                                flex: 2,
                                editing: false,
                                onDoubleTap: null,
                                onChanged: null,
                                onSubmitted: null,
                                monospace: false,
                              ),
                              _ExcelCellEditable(
                                value: product['stock']?.toString() ?? '-',
                                flex: 2,
                                editing: _editingRow == index &&
                                    _editingField == 'stock',
                                onDoubleTap: () => _onEdit(index, 'stock',
                                    product['stock']?.toString() ?? ''),
                                onChanged: (v) =>
                                    setState(() => _editingValue = v),
                                onSubmitted: () =>
                                    _onEditSubmit(index, 'stock'),
                                monospace: true,
                                editingValue: _editingRow == index &&
                                        _editingField == 'stock'
                                    ? _editingValue
                                    : null,
                              ),
                              _ExcelCellEditable(
                                value: product['price']?.toString() ?? '-',
                                flex: 2,
                                editing: _editingRow == index &&
                                    _editingField == 'price',
                                onDoubleTap: () => _onEdit(index, 'price',
                                    product['price']?.toString() ?? ''),
                                onChanged: (v) =>
                                    setState(() => _editingValue = v),
                                onSubmitted: () =>
                                    _onEditSubmit(index, 'price'),
                                monospace: true,
                                editingValue: _editingRow == index &&
                                        _editingField == 'price'
                                    ? _editingValue
                                    : null,
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          size: 20, color: Colors.blueAccent),
                                      tooltip: 'Edit',
                                      onPressed: () {
                                        // TODO: Implement edit action
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          size: 20, color: Colors.redAccent),
                                      tooltip: 'Delete',
                                      onPressed: () {
                                        // TODO: Implement delete action
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExcelHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _ExcelHeaderCell(this.label, {this.flex = 1});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

class _ExcelHeaderCellSortable extends StatelessWidget {
  final String label;
  final String column;
  final String sortColumn;
  final bool sortAsc;
  final int flex;
  final void Function(String)? onTap;
  const _ExcelHeaderCellSortable(
      this.label, this.column, this.sortColumn, this.sortAsc,
      {this.onTap, this.flex = 1});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap != null ? () => onTap!(column) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (sortColumn == column)
                Icon(sortAsc ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExcelCellEditable extends StatelessWidget {
  final String value;
  final int flex;
  final bool monospace;
  final bool editing;
  final String? editingValue;
  final VoidCallback? onDoubleTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  const _ExcelCellEditable({
    required this.value,
    this.flex = 1,
    this.monospace = false,
    this.editing = false,
    this.editingValue,
    this.onDoubleTap,
    this.onChanged,
    this.onSubmitted,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onDoubleTap: onDoubleTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: editing
              ? FocusScope(
                  child: TextField(
                    autofocus: true,
                    controller:
                        TextEditingController(text: editingValue ?? value),
                    onChanged: onChanged,
                    onSubmitted: (_) => onSubmitted?.call(),
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: monospace ? 'RobotoMono' : null,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: monospace ? 'RobotoMono' : null,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
      ),
    );
  }
}
