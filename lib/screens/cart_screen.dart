import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart' show Cart;
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/widgets/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: Consumer<Cart>(
          builder: (context, cart, _) => Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Spacer(),
                      Chip(
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: 3,
                        label: Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .title
                                  .color),
                        ),
                      ),
                      OrderButton(cart: cart,),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (ctx, index) {
                    final cartItem = cart.items.values.toList()[index];
                    return CartItem(
                        cartItem.id,
                        cart.items.keys.toList()[index],
                        cartItem.price,
                        cartItem.quantity,
                        cartItem.title);
                  },
                  itemCount: cart.itemCount,
                ),
              )
            ],
          ),
        ));
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ?CircularProgressIndicator() :Text('ORDER NOW'),
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(), widget.cart.totalAmount);
              widget.cart.clear();
              setState(() {
                _isLoading = false;
              });
              Navigator.pushNamed(context, '/orders');
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
