import 'package:flutter/material.dart';
import 'package:shopping_list/Data/categories.dart';
import 'package:shopping_list/Data/dummy_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('first-app-fb01d-default-rtdb.firebaseio.com', 'ShoppingList.json');
    final response = await http.get(url);
    // print(response.body);
    if(response.statusCode >= 400){
      setState(() {
        _error = 'An error occurred. Please try again later.';
      });
      
    }
    final List<GroceryItem> loadedItems = [];
    final Map<String,dynamic> listData = json.decode(response.body);
    for(final item in listData.entries){
      final category = categories.entries.firstWhere((element) => element.value.name == item.value['category']).value;
      loadedItems.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: category,
      ));
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    // Navigator.of(context).pushNamed('/new-item');
    final newItem = await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));
    // _loadItems();
    if(newItem == null){
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }
  void _removeItem(GroceryItem item){
    setState(() {
      _groceryItems.remove(item);
    });
  }
  @override
  Widget build(BuildContext context) {

    if(_isLoading){
      return const Center(child: CircularProgressIndicator(),);
    }

    Widget content = ListView.builder(itemCount: _groceryItems.length,itemBuilder: (ctx, index) => Dismissible(
      key: ValueKey(_groceryItems[index].id),
      onDismissed: (direction) {
        _removeItem(_groceryItems[index]);
      },
      child: ListTile(
          title: Text(_groceryItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: _groceryItems[index].category.color,
          ),
          trailing: Text(_groceryItems[index].quantity.toString(),)
        ),
    ),
      );
      
    if(_groceryItems.isEmpty){
      content = const Center(child: Text('No items yet. Add some!'),);
    }

    if(_error != null){
      content = const Center(child: Text('An error occurred. Please try again later.'),);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: content,
    );
  }
}