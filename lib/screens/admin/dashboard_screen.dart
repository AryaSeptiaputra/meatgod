import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<QueryDocumentSnapshot> orderData = [];
  Map<String, int> salesByProduct = {};

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  void processOrderData() {
    salesByProduct.clear();
    for (var order in orderData) {
      final items = (order['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (var item in items) {
        final productName = item['name'] ?? 'Unknown';
        final quantity = (item['quantity'] ?? 0) as num;
        salesByProduct[productName] =
            (salesByProduct[productName] ?? 0) + quantity.toInt();
      }
    }
  }

  Future<void> fetchOrderData() async {
    final firestore = FirebaseFirestore.instance;
    final ordersSnapshot = await firestore.collection('orders').get();

    setState(() {
      orderData = ordersSnapshot.docs;
      processOrderData();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('orders').doc(orderId).update({'status': status});
    fetchOrderData();
  }

  Widget buildChart() {
    List<BarChartGroupData> barGroups = [];
    List<String> products = salesByProduct.keys.toList();

    for (int i = 0; i < products.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: salesByProduct[products[i]]!.toDouble(),
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          barGroups: barGroups,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < products.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        products[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Product / Jumlah Penjualan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      buildChart(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: orderData.length,
                    itemBuilder: (context, index) {
                      final order = orderData[index];
                      final items = (order['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                      final status = order['status'] ?? '-';
                      final orderId = order.id;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Date: ${order['orderDate'] ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Items:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text('Name: ${item['name'] ?? '-'}'),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text('Qty: ${item['quantity'] ?? '-'}'),
                                        ),
                                      ],
                                    ),
                                  )),
                              const Divider(),
                              Text('Status: $status'),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => updateOrderStatus(orderId, 'Done'),
                                    child: const Text('Mark as Done'),
                                  ),
                                  TextButton(
                                    onPressed: () => updateOrderStatus(orderId, 'Cancelled'),
                                    child: const Text('Cancel Order'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
