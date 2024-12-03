import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTab extends StatelessWidget {
  final String userId;

  const OrderTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("Products Ordered"))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('orders')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return Center(child: Text("No orders found."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                leading: Image.network(order['image']),
                title: Text(order['name']),
                subtitle: Text("₹${order['price']} x ${order['quantity'] ?? 1} "
                    "| Total: ₹${(order['price'] * (order['quantity'] ?? 1)).toStringAsFixed(2)}"),
                trailing: Text(order['orderDate'] != null
                    ? _formatDate(order['orderDate'])
                    : 'Date Unknown'),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}
