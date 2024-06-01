import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:happiness_team_app/helpers/functions.helpers.dart';
import 'package:happiness_team_app/models/product.model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

typedef StoreProducts = List<StoreProduct>;
typedef StorePackages = List<Package>;

class PaymentsService {
  static Future<Products> fetchStoreProducts() async {
    try {
      var offerings = await Purchases.getOfferings();

      var currentOffering = offerings.current;

      if (currentOffering == null) return [];

      var products = await PaymentsService.fetchProducts();

      var customerInfo = await PaymentsService.purchaserInfo();

      return products.where((product) {
        Package? matchingPackage =
            currentOffering.availablePackages.firstWhereOrNull(
          (package) {
            return package.identifier == product.packageIdentifier;
          },
        );

        if (matchingPackage == null) return false;

        var storeProductIdentifier = matchingPackage.storeProduct.identifier;

        if (customerInfo.activeSubscriptions.contains(storeProductIdentifier)) {
          return false;
        }

        product.storePackage = matchingPackage;

        return true;
      }).toList();
    } catch (error) {
      print("No errors though?");
      return [];
    }
  }

  static Future<CustomerInfo> purchaserInfo() async {
    return await Purchases.getCustomerInfo();
  }

  static Future<void> purchasePackage(Package package) async {
    await Purchases.purchasePackage(package);
  }

  static Future<Products> fetchProducts() async {
    var snapshot =
        await FirebaseFirestore.instance.collection("products").get();

    return snapshot.docs.map((e) => Product.fromMap(fromSnapshot(e))).toList();
  }
}
