import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  IngredientModel({
    required String id,
    required String name,
    required String quantity,
    DateTime? expiryDate,
    required String category,
  }) : super(
         id: id,
         name: name,
         quantity: quantity,
         expiryDate: expiryDate,
         category: category,
       );

  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      id: ingredient.id,
      name: ingredient.name,
      quantity: ingredient.quantity,
      expiryDate: ingredient.expiryDate,
      category: ingredient.category,
    );
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      expiryDate:
          json['expiryDate'] != null
              ? (json['expiryDate'] as Timestamp).toDate()
              : null,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'category': category,
    };
  }
}
