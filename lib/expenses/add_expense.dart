import 'package:expense_tracker_app/shops/shop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:expense_tracker_app/expenses/expense_provider.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({
    Key? key,
  }) : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final TextEditingController _shopController = TextEditingController();
  var isLoading = false;
  var shop = '';
  var amount = 0.0;
  var installment = 1;

  void submitForm() async {
    setState(() {
      isLoading = true;
    });
    final data = {'shop': shop, 'amount': amount, 'installment': installment};
    String res = await Provider.of<ExpenseProvider>(context, listen: false)
        .addExpense(data);
    setState(() {
      isLoading = false;
    });
    if (res == 'done') {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop();
      });
    }
  }

  bool isAllFieldsValid() {
    return shop.isNotEmpty && amount > 0 && installment > 0;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.only(
          top: 8,
          right: 32,
          left: 32,
          bottom: 8,
        ),
        height: 300 + keyboardHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 30,
            ),
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
                _shopController.text = suggestion.toString();
                setState(() {
                  shop = suggestion.toString();
                });
              },
              suggestionsCallback: (pattern) {
                shop = pattern;
                return Provider.of<ShopProvider>(context, listen: false)
                    .searchShops(pattern);
              },
              errorBuilder: (context, error) {
                return Container();
              },
              hideOnEmpty: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _shopController,
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
                  labelText: 'חנות',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        amount = double.parse(value);
                      });
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                      labelText: 'סכום ההוצאה',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        installment = int.parse(value);
                      });
                    },
                    keyboardType: TextInputType.number,
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
                      labelText: 'תשלומים',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: isLoading || !isAllFieldsValid()
                  ? () {}
                  : () {
                      submitForm();
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'הוסף הוצאה',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
