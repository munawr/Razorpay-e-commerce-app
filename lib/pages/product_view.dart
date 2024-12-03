import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: must_be_immutable
class ProductDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot product;
  final String userId;
  const ProductDetailsPage({super.key, required this.product, required this.userId});

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
                  onPressed: () => addToWishlist(product.id, context, userId),
                  icon: Icon(Icons.favorite_border),
                  label: Text("Add to Wishlist"),
                ),
                ElevatedButton.icon(
                  onPressed: () => addToCart(product.id, context, userId),
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

  Future<void> addToWishlist(
      String productId, BuildContext context, String userId) async {
    final wishlistRef = FirebaseFirestore.instance
        .collection('users') 
        .doc(userId) 
        .collection('wishlist') 
        .doc(productId); 

    try {
      await wishlistRef.set({
        'id': productId,
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'description': product['description'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added to Wishlist"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            padding: EdgeInsets.only(bottom: 60),
            backgroundColor: Colors.green,
            content: Text("Failed to add to Wishlist")),
      );
    }
  }

  Future<void> addToCart(
      String productId, BuildContext context, String userId) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId);

    try {
      final docSnapshot = await cartRef.get();
      if (docSnapshot.exists) {
        await cartRef.update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        await cartRef.set({
          'id': productId,
          'name': product['name'],
          'price': product['price'],
          'image': product['image'],
          'description': product['description'],
          'quantity': 1,
          'paid': false,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Added to Cart"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add to Cart")),
      );
    }
  }
}
