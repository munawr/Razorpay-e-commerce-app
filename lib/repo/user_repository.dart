// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'product_repository.dart';

// class UserRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String _userId;

//   UserRepository(this._userId);

//   Future<List<Product>> fetchCartItems() async {
//     final snapshot = await _firestore.collection('users').doc(_userId).collection('cart').get();
//     return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
//   }

//   Future<void> addToCart(Product product) async {
//     final cartRef = _firestore.collection('users').doc(_userId).collection('cart').doc(product.id);
//     await cartRef.set(product.toJson());
//   }

//   Future<void> removeFromCart(String productId) async {
//     final cartRef = _firestore.collection('users').doc(_userId).collection('cart').doc(productId);
//     await cartRef.delete();
//   }

//   Future<List<Product>> fetchWishlistItems() async {
//     final snapshot = await _firestore.collection('users').doc(_userId).collection('wishlist').get();
//     return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
//   }

//   Future<void> addToWishlist(Product product) async {
//     final wishlistRef = _firestore.collection('users').doc(_userId).collection('wishlist').doc(product.id);
//     await wishlistRef.set(product.toJson());
//   }

//   Future<void> removeFromWishlist(String productId) async {
//     final wishlistRef = _firestore.collection('users').doc(_userId).collection('wishlist').doc(productId);
//     await wishlistRef.delete();
//   }
// }

// extension ProductToJson on Product {
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'name': name,
//     'price': price,
//     'image': image,
//     'description': description,
//   };
// }