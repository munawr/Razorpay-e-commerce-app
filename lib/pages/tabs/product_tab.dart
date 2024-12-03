import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class ProductDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot product;
  String userId;
  ProductDetailsPage({super.key, required this.product, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product['image'],
                height: 200,
              ),
            ),
            SizedBox(height: 16),
            Text(
              product['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${product['price']}",
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            SizedBox(height: 16),
            Text(product['description']),
            if (product['offers'])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "Offer available!",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => addToWishlist(product.id, product, context),
                  icon: Icon(Icons.favorite_border),
                  label: Text("Add to Wishlist"),
                ),
                ElevatedButton.icon(
                  onPressed: () => addToCart(product.id, product, context),
                  icon: Icon(Icons.shopping_cart),
                  label: Text("Add to Cart"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToWishlist(String productId, QueryDocumentSnapshot product,
      BuildContext context) async {
    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId);

    try {
      final existingWishlistItem = await wishlistRef.get();

      if (!existingWishlistItem.exists) {
        final productData = product.data() as Map<String, dynamic>;

        await wishlistRef.set({
          'id': product.id,
          'name': productData['name'] ?? 'Unknown Product', 
          'price': productData['price'] ?? 0, 
          'image': productData['image'] ?? '', 
          'description':
              productData['description'] ?? 'No description available',
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Added to Wishlist")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Item already exists in Wishlist")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add to Wishlist: $e")));
    }
  }

  Future<void> addToCart(
    String productId,
    QueryDocumentSnapshot product,
    BuildContext context, {
    int quantity = 1,
  }) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    try {
      final existingCartItem = await cartRef.get();

      if (existingCartItem.exists) {
        await cartRef.update({
          'quantity': FieldValue.increment(quantity),
        });
      } else {
        print(">>>>>>>>>>>>>>>${productId}");
        await cartRef.set({
          'productId': product.id,
          'name': product['name'],
          'price': product['price'],
          'image': product['image'],
          'quantity': quantity,
          'paid': false, // Explicitly set paid to false
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Added to Cart")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to add to Cart")));
    }
  }
}
