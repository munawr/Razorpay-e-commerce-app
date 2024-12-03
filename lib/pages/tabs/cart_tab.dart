import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CartTab extends StatefulWidget {
  final String userId;

  const CartTab({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _CartTabState createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  late Razorpay _razorpay;
  double totalPrice = 0.0;
  List<QueryDocumentSnapshot> cartItems = [];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _calculateTotalPrice() {
    totalPrice = cartItems.fold(0.0,
        (total, item) => total + (item['price'] * (item['quantity'] ?? 1)));
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(widget.userId);

    try {
      WriteBatch batch = firestore.batch();

      for (var cartItem in cartItems) {
        final cartItemData = cartItem.data() as Map<String, dynamic>;
        final productId = cartItem.id;

        DocumentReference cartItemRef =
            userDocRef.collection('cart').doc(productId);
        DocumentReference orderRef =
            userDocRef.collection('orders').doc(productId);

        Map<String, dynamic> orderData = {
          ...cartItemData,
          'paid': true,
          'orderDate': FieldValue.serverTimestamp(),
        };

        batch.set(orderRef, orderData);
        batch.delete(cartItemRef);
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment successful! Order placed."),
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
          content: Text("Error processing order: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkout() {
    if (totalPrice <= 0) {
      return;
    }

    var options = {
      'key': 'rzp_test_oC64wPmDU63JoK',
      'amount': (totalPrice * 100).toInt(),
      'name': 'E-Commerce App',
      'description': 'Payment for cart items',
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initializing payment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          cartItems =
              snapshot.data!.docs.where((doc) => doc['paid'] == false).toList();
          _calculateTotalPrice();

          if (cartItems.isEmpty) {
            return Center(child: Text("Your cart is empty."));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    print("Rendering cart item: ${item.id}");
                    return ListTile(
                      leading: Image.network(item['image']),
                      title: Text(item['name']),
                      subtitle:
                          Text("₹${item['price']} x ${item['quantity'] ?? 1}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "₹${(item['price'] * (item['quantity'] ?? 1)).toStringAsFixed(2)}"),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeFromCart(item.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total Price: ₹${totalPrice.toStringAsFixed(2)}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: cartItems.isNotEmpty ? _checkout : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text("Checkout"),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeFromCart(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('cart')
          .doc(productId)
          .delete();
      print("Removed product $productId from cart.");
    } catch (e) {
      print("Error removing product $productId: $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment error: ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External wallet selected: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External wallet selected: ${response.walletName}"),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
