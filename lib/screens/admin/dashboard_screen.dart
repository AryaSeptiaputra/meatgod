import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<QueryDocumentSnapshot> orderData = [];

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    final firestore = FirebaseFirestore.instance;
    final ordersSnapshot = await firestore.collection('order').get();

    setState(() {
      orderData = ordersSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: orderData.isEmpty
            ? Center(child: CircularProgressIndicator())
            : DataTable(
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Status')),
                ],
                rows: orderData.map((order) {
                  DateTime date = (order['createdAt'] as Timestamp).toDate();
                  return DataRow(cells: [
                    DataCell(Text(order.id)),
                    DataCell(Text('${date.year}-${date.month}-${date.day}')),
                    DataCell(Text(order['status'] ?? 'Unknown')),
                  ]);
                }).toList(),
              ),
      ),
    );
  }
}