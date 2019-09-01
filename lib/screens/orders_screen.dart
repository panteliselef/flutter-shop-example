import 'package:flutter/material.dart';
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';
import 'package:my_shop/providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAdnSetOrders(),
          builder: (ctx, dateSnapshot) {
            if (dateSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (dateSnapshot.error != null) {
              return Center(
                child: Text("An error occured"),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, ordersData, _) => ListView.builder(
                  itemBuilder: (ctx, index) {
                    return OrderItem(ordersData.orders[index]);
                  },
                  itemCount: ordersData.orders.length,
                ),
              );
            }
          },
        ));
  }
}
