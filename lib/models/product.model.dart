// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

enum ProductType {
  subscription,
  purchase,
}

typedef Products = List<Product>;

class Product {
  String id;
  String packageIdentifier;
  ProductType type;
  String label;
  int displayOrder;
  Package? storePackage;

  Product({
    required this.id,
    required this.packageIdentifier,
    required this.label,
    required this.type,
    required this.displayOrder,
    this.storePackage,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'packageIdentifier': packageIdentifier,
      'label': label,
      'displayOrder': displayOrder,
      'type': type.name,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      packageIdentifier: map['packageIdentifier'] as String,
      label: map['label'] as String,
      type: ProductType.values.firstWhere(
        (element) => element.name == map['type'],
      ),
      displayOrder: map['displayOrder'] as int,
    );
  }
}
