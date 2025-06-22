import 'package:flutter/material.dart';
import '../../data/data_providers/product_api.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String _search = '';
  String _stockFilter = 'all'; // 'all', 'low', 'out'

  @override
  void initState() {
    super.initState();
    fetchProductsWithStock();
  }

  Future<void> fetchProductsWithStock() async {
    setState(() => isLoading = true);
    final result = await ProductApiService.getProductsWithStock();
    setState(() {
      products = result['success'] == true && result['data'] != null
          ? List<Map<String, dynamic>>.from(result['data'])
          : [];
      isLoading = false;
    });
  }

  void _showStockDialog(Map<String, dynamic> product, bool isStockIn) {
    final controller = TextEditingController();
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isStockIn ? 'Stock In' : 'Stock Out'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product: ${product['name']}'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(controller.text.trim());
                if (qty == null || qty <= 0) return;
                final note = noteController.text.trim();
                final res = isStockIn
                    ? await ProductApiService.stockIn(product['id'], qty, note)
                    : await ProductApiService.stockOut(
                        product['id'], qty, note);
                if (res['success'] == true) {
                  Navigator.pop(context);
                  fetchProductsWithStock();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Stock updated successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(res['error'] ?? 'Failed to update stock')),
                  );
                }
              },
              child: Text(isStockIn ? 'Add Stock' : 'Remove Stock'),
            ),
          ],
        );
      },
    );
  }

  void _showStockLog(
      BuildContext context, int productId, String productName) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: FutureBuilder<Map<String, dynamic>>(
            future: ProductApiService.getStockLog(productId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snapshot.data!;
              final logs = data['success'] == true && data['data'] != null
                  ? List<Map<String, dynamic>>.from(data['data'])
                  : [];
              return SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Stock Log for $productName',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const Divider(),
                    if (logs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No stock movement found.'),
                      )
                    else
                      SizedBox(
                        height: 320,
                        child: ListView.separated(
                          itemCount: logs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final log = logs[i];
                            return ListTile(
                              leading: Icon(
                                log['type'] == 'in'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: log['type'] == 'in'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                  '${log['type'] == 'in' ? 'Stock In' : 'Stock Out'}: ${log['quantity']}'),
                              subtitle: Text(
                                  '${log['note'] ?? ''}\nBy: ${log['performed_by'] ?? 'N/A'}'),
                              trailing: Text(log['date'] ?? ''),
                            );
                          },
                        ),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> get filteredList {
    var list = products;
    if (_stockFilter == 'low') {
      list = list
          .where((p) => (p['stock'] ?? 0) > 0 && (p['stock'] ?? 0) <= 5)
          .toList();
    } else if (_stockFilter == 'out') {
      list = list.where((p) => (p['stock'] ?? 0) == 0).toList();
    }
    if (_search.isNotEmpty) {
      list = list
          .where((p) =>
              (p['name']?.toString().toLowerCase() ?? '')
                  .contains(_search.toLowerCase()) ||
              (p['sku']?.toString().toLowerCase() ?? '')
                  .contains(_search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchProductsWithStock,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name or SKU...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onChanged: (v) => setState(() => _search = v),
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      children: [
                        FilterChip(
                          label: Text('All'),
                          selected: _stockFilter == 'all',
                          onSelected: (_) =>
                              setState(() => _stockFilter = 'all'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Low Stock'),
                          selected: _stockFilter == 'low',
                          onSelected: (_) =>
                              setState(() => _stockFilter = 'low'),
                          backgroundColor: Colors.orange[100],
                          selectedColor: Colors.orange[300],
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Out of Stock'),
                          selected: _stockFilter == 'out',
                          onSelected: (_) =>
                              setState(() => _stockFilter = 'out'),
                          backgroundColor: Colors.red[100],
                          selectedColor: Colors.red[300],
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 900,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                const Color(0xFFe3f2fd)),
                            columns: const [
                              DataColumn(
                                  label: Text('Product Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('SKU',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Current Stock',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Actions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: filteredList.map((product) {
                              return DataRow(cells: [
                                DataCell(
                                    Text(product['name']?.toString() ?? '-')),
                                DataCell(
                                    Text(product['sku']?.toString() ?? '-')),
                                DataCell(
                                  Row(
                                    children: [
                                      Text(product['stock']?.toString() ?? '-',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      if ((product['stock'] ?? 0) == 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: Icon(Icons.warning,
                                              color: Colors.red, size: 18),
                                        )
                                      else if ((product['stock'] ?? 0) <= 5)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: Icon(Icons.error_outline,
                                              color: Colors.orange, size: 18),
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_downward,
                                          color: Colors.green),
                                      tooltip: 'Stock In',
                                      onPressed: () =>
                                          _showStockDialog(product, true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_upward,
                                          color: Colors.red),
                                      tooltip: 'Stock Out',
                                      onPressed: () =>
                                          _showStockDialog(product, false),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.history,
                                          color: Colors.blueAccent),
                                      tooltip: 'View Log',
                                      onPressed: () => _showStockLog(
                                          context,
                                          product['id'],
                                          product['name']?.toString() ?? ''),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.orange),
                                      tooltip: 'Edit Product',
                                      onPressed: () {
                                        // TODO: Implement edit product
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      tooltip: 'Delete Product',
                                      onPressed: () {
                                        // TODO: Implement delete product
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
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
