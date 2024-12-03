import 'package:e_commerce/pages/tabs/cart_tab.dart';
import 'package:e_commerce/pages/tabs/home_tab.dart';
import 'package:e_commerce/pages/tabs/order_tab.dart';
import 'package:e_commerce/pages/tabs/wishlist_tab.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String uid;

  const HomeScreen({super.key, required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final TextEditingController searchController = TextEditingController();
  // final String searchQuery = "";
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.uid}!"),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(
            userId: widget.uid,
          ),
          WishlistTab(
            userId: widget.uid,
          ),
          CartTab(
            userId: widget.uid,
          ),
          OrderTab(userId: widget.uid),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        unselectedItemColor: Colors.black38,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
        ],
      ),
    );
  }
}
