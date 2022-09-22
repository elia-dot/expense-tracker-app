import 'package:expense_tracker_app/shops/shops_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expense_tracker_app/shops/shop.dart';

class ShopsPage extends StatefulWidget {
  static const routeName = '/shops';
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  Future<void> shopsFuture = Future.value();

  Future<void> getShops() async {
    final shopsProvider = Provider.of<ShopProvider>(context, listen: false);
    await shopsProvider.fetchAndSetShops();
    await shopsProvider.getCategoriesSum();
  }

  @override
  void initState() {
    getShops();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shopsProvider = Provider.of<ShopProvider>(context);
    List<Map<String, List<Shop>>> shops = shopsProvider.groupShops;
    Map<String, dynamic> categoryExpenses = shopsProvider.categoryExpenses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('חנויות'),
      ),
      body: shops.isEmpty
          ? const Center(
              child: Text('אין חנויות'),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'קטגוריות',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: ShopsList(shops: shops, categoryExpenses: categoryExpenses),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
