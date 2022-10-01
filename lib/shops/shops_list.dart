import 'package:expandable/expandable.dart';
import 'package:expense_tracker_app/shops/shop_image.dart';
import 'package:expense_tracker_app/utils/formater.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker_app/shops/shop_details.dart';
import 'package:expense_tracker_app/shops/shop.dart';

class ShopsList extends StatefulWidget {
  final List<Map<String, List<Shop>>> shops;
  final Map<String, dynamic> categoryExpenses;
  const ShopsList(
      {super.key, required this.shops, required this.categoryExpenses});

  @override
  State<ShopsList> createState() => _ShopsListState();
}

class _ShopsListState extends State<ShopsList> {
  String shopsNumber(List shops) {
    String text = '';
    if (shops.length == 1) {
      text = 'חנות אחת';
    } else if (shops.length > 1) {
      text = '${shops.length} חנויות';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: widget.shops.length,
        itemBuilder: (context, index) {
          return ExpandablePanel(
            header: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.shops[index].keys.first,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        shopsNumber(widget.shops[index]
                            [widget.shops[index].keys.first]!),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (widget.categoryExpenses[widget.shops[index].keys.first] !=
                      null)
                    Text(expenseAmount(widget
                        .categoryExpenses[widget.shops[index].keys.first]
                        .toDouble())),
                ],
              ),
            ),
            collapsed: Container(),
            expanded: Container(
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
                  for (var shop in widget.shops[index]
                      [widget.shops[index].keys.first]!)
                    Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ShopDetails.routeName,
                              arguments: shop,
                            );
                          },
                          style: ListTileStyle.list,
                          leading: shop.imageUrl != null
                              ? ShopImage(
                                  imageUrl: cloudinaryUrl(shop.imageUrl!),
                                  size: 40,
                                )
                              : shop.isOnline
                                  ? const Icon(Icons.computer_outlined)
                                  : const Icon(Icons.home),
                          title: Text(shop.name),
                          trailing: Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (shop !=
                            widget.shops[index][widget.shops[index].keys.first]!
                                .last)
                          const Divider(
                            height: 0,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
