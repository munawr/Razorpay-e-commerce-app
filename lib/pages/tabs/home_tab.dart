import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../product_view.dart';

class HomeTab extends StatefulWidget {
  final  String userId;
  const HomeTab({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = "";
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;
                final filteredProducts = products.where((product) {
                  final productName = product['name'].toString().toLowerCase();
                  return productName.contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                      child: Text("No products match your search."));
                }
                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ListTile(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(
                              product: product, userId: widget.userId,
                            ),
                          )),
                      title: Text(product['name']),
                      subtitle: Text("Price: ₹${product['price']}"),
                      leading: product['image'] != null
                          ? Image.network(product['image'],
                              width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
