import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imgUrlController = TextEditingController();
  final _imgUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _isLoading = false;
  var _isInit = true;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _editProduct =
      Product(id: null, title: '', price: 0, description: "", imageUrl: '');

  @override
  void initState() {
    _imgUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': '',
        };
        _imgUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imgUrlFocusNode.hasFocus) {
      if (_imgUrlController.text.isEmpty ||
          !_imgUrlController.text.startsWith('http') &&
              !_imgUrlController.text.startsWith('https')) {
        return;
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _imgUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imgUrlController.dispose();
    _imgUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) return;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("An error occured!"),
              content: Text(error.toString()),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            );
          },
        );
      }
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct);
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _form,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      validator: (value) {
                        if (!value.isEmpty) return null;
                        return 'Provide a title';
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      onSaved: (value) {
                        _editProduct = Product(
                            title: value,
                            price: _editProduct.price,
                            description: _editProduct.description,
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            imageUrl: _editProduct.imageUrl);
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      validator: (value) {
                        if (value.isEmpty) return 'Enter Price';
                        if (double.tryParse(value) == null) {
                          return 'Enter Valid Number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Invalid Price';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            title: _editProduct.title,
                            price: double.parse(value),
                            description: _editProduct.description,
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            imageUrl: _editProduct.imageUrl);
                      },
                      focusNode: _priceFocusNode,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_descFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      validator: (value) {
                        if (value.isEmpty) return 'Enter Description';
                        if (value.length < 10) {
                          return 'Min.Characters: 10';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editProduct = Product(
                            title: _editProduct.title,
                            price: _editProduct.price,
                            description: value,
                            id: _editProduct.id,
                            isFavorite: _editProduct.isFavorite,
                            imageUrl: _editProduct.imageUrl);
                      },
                      maxLines: 3,
                      focusNode: _descFocusNode,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imgUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : Image.network(
                                  _imgUrlController.text,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Image URL",
                            ),
                            validator: (value) {
                              if (value.isEmpty) return 'Enter an image URL';
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https'))
                                return 'Enter Valid URL';
                              return null;
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                  title: _editProduct.title,
                                  price: _editProduct.price,
                                  description: _editProduct.description,
                                  id: _editProduct.id,
                                  isFavorite: _editProduct.isFavorite,
                                  imageUrl: value);
                            },
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imgUrlFocusNode,
                            controller: _imgUrlController,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
