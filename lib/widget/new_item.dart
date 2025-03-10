import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/Data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;
  void saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();
      final url = Uri.https('first-app-fb01d-default-rtdb.firebaseio.com', 'ShoppingList.json');
      final response = await http.post(url,headers: {'Content-Type':'application/json'},body: json.encode({
        'name': _enteredName,
        'quantity': _enteredQuantity,
        'category': _selectedCategory.name,
      }));
      // Navigator.of(context).pop(
        
      // );
      // print(response.body);
      // print(response.statusCode);
      final Map<String, dynamic> resData = json.decode(response.body); // tối ưu hóa code
      if(!context.mounted){
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode
              .onUserInteraction, //dùng để kiểm tra validate ngay khi người dùng nhập liệu
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value == null) {
                    return;
                  }
                  _enteredName = value;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number';
                        }
                        return null;
                      },
                      onSaved: (value){
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(value: _selectedCategory,items: [
                      for (final category in categories.entries)
                        DropdownMenuItem(
                          value: category.value,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(category.value.name),
                            ],
                          ),
                        )
                    ], onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    }),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending ? null : () {
                        _formKey.currentState!.reset();
                      },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: _isSending ? null : saveItem, child: _isSending ? const SizedBox(width: 16,height: 16, child: CircularProgressIndicator(),): const Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
