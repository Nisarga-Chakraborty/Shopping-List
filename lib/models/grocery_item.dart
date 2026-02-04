import "package:flutter/material.dart";
import "package:shopping_list/models/category.dart";

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
  });

  // ignore: empty_constructor_bodies
  final String id;
  final Category category;
  final String name;
  final int quantity;
}
