import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:expense_tracker_app/expenses/expense_provider.dart';
import 'package:expense_tracker_app/shops/shop.dart';
import 'package:expense_tracker_app/utils/formater.dart';

enum ShopDeatilsMode { view, edit }

class ShopDetails extends StatefulWidget {
  static const routeName = '/shop_details';
  const ShopDetails({super.key});

  @override
  State<ShopDetails> createState() => _ShopDetailsState();
}

class _ShopDetailsState extends State<ShopDetails> {
  final TextEditingController _categoryController = TextEditingController();
  ShopDeatilsMode mode = ShopDeatilsMode.view;
  bool isOnline = false;
  String category = '';
  bool isLoading = false;

  Future<void> update(String shopId) async {
    setState(() {
      isLoading = true;
    });
    final data = {
      'category': category,
      'isOnline': isOnline,
    };
    String res = await Provider.of<ShopProvider>(context, listen: false)
        .updateShop(shopId, data);
    if (res == 'done') {
      setState(() {
        mode = ShopDeatilsMode.view;
      });
      Future.delayed(Duration.zero, () {
        Provider.of<ExpenseProvider>(context, listen: false)
            .fetchAndSetExpenses();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Shop shop = ModalRoute.of(context)!.settings.arguments as Shop;
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      shopProvider.getShopExpenses(shop);
      setState(() {
        isOnline = shop.isOnline;
        category = shop.category;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Shop shopArgs = ModalRoute.of(context)!.settings.arguments as Shop;
    final shopProvider = Provider.of<ShopProvider>(context);
    final shop = shopProvider.currentShop(shopArgs.id);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(shop.name),
          actions: [
            if (mode == ShopDeatilsMode.view)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    mode = ShopDeatilsMode.edit;
                  });
                },
              ),
            if (mode == ShopDeatilsMode.edit && !isLoading)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  update(shop.id);
                },
              ),
            if (isLoading)
              SizedBox(
                width: 50,
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  color: Theme.of(context).primaryColor,
                ),
              ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                  if (mode == ShopDeatilsMode.edit)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                shop.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mode == ShopDeatilsMode.view) Text(shop.category),
              const SizedBox(
                height: 20,
              ),
              if (mode == ShopDeatilsMode.view)
                for (Expense expense in shop.expenses)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              expenseAmount(expense.amount),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              dateFormater.format(expense.date),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              if (mode == ShopDeatilsMode.edit)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TypeAheadField(
                          itemBuilder: (context, itemData) {
                            return Directionality(
                              textDirection: TextDirection.rtl,
                              child: ListTile(
                                title: Text(itemData.toString()),
                              ),
                            );
                          },
                          onSuggestionSelected: (suggestion) {
                            _categoryController.text = suggestion.toString();
                            setState(() {
                              category = suggestion.toString();
                            });
                          },
                          suggestionsCallback: (pattern) {
                            category = pattern;
                            return Provider.of<ShopProvider>(context,
                                    listen: false)
                                .searchCategories(pattern);
                          },
                          errorBuilder: (context, error) {
                            return Container();
                          },
                          hideOnEmpty: true,
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _categoryController,
                            autofocus: true,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              labelText: 'קטגוריה',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Switch.adaptive(
                              value: isOnline,
                              onChanged: (value) {
                                setState(() {
                                  isOnline = value;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text('חנות אינטרנטית'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
