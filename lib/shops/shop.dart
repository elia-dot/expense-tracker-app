import 'dart:convert';

import 'package:expense_tracker_app/user/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:expense_tracker_app/utils/headers.dart';
import 'package:expense_tracker_app/expenses/expense_provider.dart';

class Shop {
  String id;
  String name;
  String category;
  bool isOnline;
  String createdForGroupId;
  List<Expense> expenses;

  Shop({
    required this.id,
    required this.name,
    required this.category,
    required this.isOnline,
    required this.createdForGroupId,
    this.expenses = const [],
  });
}

class ShopProvider with ChangeNotifier {
  final List<Map<String, List<Shop>>> _shops = [];
  Map<String, dynamic> _categoryExpenses = {};
  List<String> shopSearchResults = [];

  List<Map<String, List<Shop>>> get groupShops {
    return _shops;
  }

  Map<String, dynamic> get categoryExpenses {
    return _categoryExpenses;
  }

  Future<void> fetchAndSetShops() async {
    final res = await http.get(
      Uri.parse('${dotenv.env['API']}/shops/shops-by-category'),
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> categories = data;

      for (var category in categories) {
        final List<Shop> shops = [];
        String categoryName = category['category'];
        final List<dynamic> shopsList = category['shops'];
        for (var shop in shopsList) {
          Shop newShop = Shop(
            id: shop['_id'],
            name: shop['name'],
            category: category['category'],
            isOnline: shop['isOnline'],
            createdForGroupId: shop['createdForGroupId'],
          );
          shops.add(newShop);
        }
        var currentCategory = _shops.firstWhere(
          (element) => element.keys.first == categoryName,
          orElse: () => {},
        );
        if (currentCategory.isEmpty) {
          _shops.add({categoryName: shops});
        } else {
          currentCategory[categoryName] = shops;
        }
      }
      notifyListeners();
    }
  }

  Future<void> getShopExpenses(Shop shop) async {
    final res = await http.get(
      Uri.parse('${dotenv.env['API']}/expenses/shop/${shop.id}'),
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> expenses = data['expenses'];
      final List<Expense> shopExpenses = [];
      for (var expense in expenses) {
        Expense newExpense = Expense(
          shop: shop,
          id: expense['_id'],
          amount: expense['amount'].toDouble(),
          description: expense['description'],
          date: DateTime.parse(expense['date']),
          createdBy: User(
            id: expense['createdBy']['_id'],
            name: expense['createdBy']['name'],
            email: expense['createdBy']['email'],
            isPasswordConfirm: expense['createdBy']['isPasswordConfirm'],
            monthlyBudget: expense['createdBy']['monthlyBudget'].toDouble(),
            allowNotifications:
                expense['createdBy']['allowNotifications'] as bool,
          ),
        );
        shopExpenses.add(newExpense);
      }
      for (var element in _shops) {
        element.forEach((key, value) {
          for (Shop currentShop in value) {
            if (currentShop.id == shop.id) {
              shop.expenses = shopExpenses;
            }
          }
        });
      }
      notifyListeners();
    }
  }

  Shop currentShop(String shopId) {
    Shop currentShop = Shop(
      id: '',
      name: '',
      category: '',
      isOnline: false,
      createdForGroupId: '',
    );
    for (var element in _shops) {
      element.forEach((key, value) {
        for (Shop shop in value) {
          if (shop.id == shopId) {
            currentShop = shop;
          }
        }
      });
    }
    return currentShop;
  }

  Future<String> updateShop(String id, Map data) async {
    final res = await http.patch(
      Uri.parse('${dotenv.env['API']}/shops/$id'),
      headers: await headers(),
      body: json.encode(data),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      var updatedShop = data['shop'];
      for (var element in _shops) {
        element.forEach((key, value) {
          for (Shop shop in value) {
            if (shop.id == id) {
              shop.name = updatedShop['name'];
              shop.category = updatedShop['category'];
              shop.isOnline = updatedShop['isOnline'];
            }
          }
        });
      }
      Shop shop = currentShop(id);
      getShopExpenses(shop);

      int oldCategoryIndex = -1;
      String oldCategoryName = '';

      var newCategoryIndex = _shops.indexWhere(
        (element) => element.keys.first == shop.category,
      );

      //find old category index
      for (var element in _shops) {
        element.forEach((key, value) {
          if (value.any(
              (element) => element.id == shop.id && key != shop.category)) {
            oldCategoryIndex = _shops.indexOf(element);
            oldCategoryName = key;
          }
        });
        if (oldCategoryIndex != -1) {
          break;
        }
      }

      if (oldCategoryIndex != -1) {
        //remove shop from old category
        _shops[oldCategoryIndex][oldCategoryName]!.removeWhere(
          (element) => element.id == shop.id,
        );
        //add shop to new category
        if (newCategoryIndex == -1) {
          _shops.add({
            shop.category: [shop]
          });
        } else {
          _shops[newCategoryIndex][shop.category]!.add(shop);
        }

        //remove old category if empty
        if (_shops[oldCategoryIndex][oldCategoryName]!.isEmpty) {
          _shops.removeAt(oldCategoryIndex);
        }
      }

      notifyListeners();
      return 'done';
    } else {
      debugPrint(res.body);
      return 'error';
    }
  }

  Future<void> getCategoriesSum() async {
    final res = await http.get(
      Uri.parse('${dotenv.env['API']}/expenses/by-category'),
      headers: await headers(),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      _categoryExpenses = data;
      notifyListeners();
    }
  }

  Future<List<String>> searchShops(String query) async {
    List<String> searchedShops = [];
    if (query.isNotEmpty) {
      var body = json.encode({'term': query});
      final res = await http.post(
        Uri.parse('${dotenv.env['API']}/shops/search/'),
        body: body,
        headers: await headers(),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        for (var shop in data) {
          searchedShops.add(shop['name']);
        }
        searchedShops = searchedShops.toSet().toList();
      }
    }

    return searchedShops.length > 4
        ? searchedShops.sublist(0, 4)
        : searchedShops;
  }

  Future<List<String>> searchCategories(String query) async {
    List<String> searchedCategories = [];
    if (query.isNotEmpty) {
      var body = json.encode({'term': query});
      final res = await http.post(
        Uri.parse('${dotenv.env['API']}/shops/categories/search/'),
        body: body,
        headers: await headers(),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        for (var category in data) {
          searchedCategories.add(category);
        }
        searchedCategories = searchedCategories.toSet().toList();
      }
    }

    return searchedCategories.length > 5
        ? searchedCategories.sublist(0, 5)
        : searchedCategories;
  }
}
