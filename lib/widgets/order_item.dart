import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderItem;

  OrderItem(this.orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _showDetails = false;

  void toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _showDetails
          ? min(widget.orderItem.products.length * 20.0 + 110, 200.0)
          : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                '\$${widget.orderItem.amount.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato'),
              ),
              subtitle: Text(DateFormat('dd/MM/yyyy hh:mm')
                  .format(widget.orderItem.dateTime)),
              trailing: IconButton(
                icon:
                    Icon(_showDetails ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  toggleDetails();
                },
              ),
            ),
            AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _showDetails
                    ? min(widget.orderItem.products.length * 20.0 + 10, 100.0)
                    : 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  height:
                      min(widget.orderItem.products.length * 20.0 + 10, 100.0),
                  child: ListView(
                    children: widget.orderItem.products.map((product) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            product.title,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${product.quantity}x \$${product.price}',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
