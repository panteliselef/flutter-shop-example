import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_shop/providers/cart.dart';
class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id,this.productId, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction){
        return showDialog(context: context,builder: (ctx)=> AlertDialog(
          title: Text('Are you sure ?'),
          content: Text('You are about to remove an item from the cart'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: (){
                Navigator.of(ctx).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: (){
                Navigator.of(ctx).pop(true);
              },
            )
          ],
        ));
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topRight: const Radius.circular(5),
              bottomRight: const Radius.circular(5)),
          color: Theme.of(context).errorColor,
        ),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
      ),
      onDismissed: (direction){
        if(direction == DismissDirection.endToStart) {
          Provider.of<Cart>(context,listen: false).removeItem(productId);
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: FittedBox(child: Text('\$${price}')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total \$${price * quantity}'),
            trailing: Text('${quantity}x'),
          ),
        ),
      ),
    );
  }
}
