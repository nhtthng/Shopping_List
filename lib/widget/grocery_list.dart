import 'package:flutter/material.dart';
import 'package:shopping_list/Data/dummy_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  void _addItem() async {
    // Navigator.of(context).pushNamed('/new-item');
    final newItem = await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));
    if(newItem == null){
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget content = ListView.builder(itemCount: _groceryItems.length,itemBuilder: (ctx, index) => ListTile(
        title: Text(_groceryItems[index].name),
        leading: Container(
          width: 24,
          height: 24,
          color: _groceryItems[index].category.color,
        ),
        trailing: Text(_groceryItems[index].quantity.toString(),)
      ),
      );
      
    if(_groceryItems.isEmpty){
      content = const Center(child: Text('No items yet. Add some!'),);
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