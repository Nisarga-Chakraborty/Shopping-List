import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import "package:http/http.dart" as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https(
      "flutter-project-7283b-default-rtdb.firebaseio.com", // url to my firebase project
      "shopping-list.json", // subheading to access specific data
    );
    try {
      final response = await http.get(
        url,
      ); // Fetch data from backend here Firebase

      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something Went Wrong! Please try again later."),
            duration: Duration(seconds: 4),
          ),
        );
      }
      final responseData = json.decode(response.body);
      final List<GroceryItem> _loadedItem = [];

      if (response.body == null) {
        setState(() {
          _isLoading = false;
          _groceryItems = [];
        });
      }
      if (responseData is! Map<String, dynamic>) {
        // Unexpected format
        setState(() {
          _isLoading = false;
        });
        return;
      }

      for (final item in responseData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value["category"],
            )
            .value;
        _loadedItem.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems =
            _loadedItem; // assigning loaded items to the grocery items list
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch data. Please check your connection."),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
  /*void _loadItems() async {
    final url = Uri.https(
      "flutter-project-7283b-default-rtdb.firebaseio.com",
      "shopping-list.json",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong! Please try again later."),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return; // stop here
      }

      final responseData = json.decode(response.body);

      if (responseData == null) {
        setState(() {
          _isLoading = false;
          _groceryItems = [];
        });
        return;
      }

      if (responseData is! Map<String, dynamic>) {
        // Unexpected format
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<GroceryItem> loadedItems = [];
      for (final item in responseData.entries) {
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value["category"],
            )
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch data. Please check your connection."),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }*/

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));
    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
    _loadItems(); // loading theitems after adding new item
  }

  void _removeItem(String id) async {
    final url = Uri.https(
      "flutter-project-7283b-default-rtdb.firebaseio.com", // url to my firebase project
      "shopping-list/$id.json", // subheading to access a specific item to delete from the backend
    );
    final delete_response = await http.delete(
      url,
    ); // send delete request to the backend

    if (delete_response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Sorry could not delete item",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Item successfully deleted",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _groceryItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Shopping List",
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _addItem)],
      ),
      backgroundColor: const Color.fromARGB(161, 0, 0, 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groceryItems.isEmpty
          ? const Center(
              child: Text(
                "No items added yet.",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _groceryItems.length,
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                onDismissed: (direction) {
                  final removedItem = _groceryItems[index];
                  _removeItem(_groceryItems[index].id);
                },
                child: ListTile(
                  title: Text(_groceryItems[index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
              ),
            ),
    );
  }
}
