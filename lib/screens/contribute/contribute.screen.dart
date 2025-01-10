import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/contribute_list/contribute_list_item.widget.dart';
import 'package:happiness_team_app/models/product.model.dart';
import 'package:happiness_team_app/services/payments.service.dart';

@RoutePage()
class ContributeScreen extends StatefulWidget {
  const ContributeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Support Us'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Divider(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: FutureBuilder(
        future: PaymentsService.fetchStoreProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var products = snapshot.data as Products;
          var purchaseProducts = products.where((product) {
            return product.type == ProductType.purchase;
          }).toList();
          purchaseProducts.sort(
            (a, b) => a.displayOrder.compareTo(b.displayOrder),
          );

          var subscriptionProducts = products.where((product) {
            return product.type == ProductType.subscription;
          }).toList();

          subscriptionProducts.sort(
            (a, b) => a.displayOrder.compareTo(b.displayOrder),
          );

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Support the Happiness Team in our mission to make the world a happier place",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    "One-time purchases",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: purchaseProducts.length,
                    itemBuilder: (context, index) {
                      return ContributeListItem(
                        product: purchaseProducts[index],
                      );
                    },
                  ),
                  if (subscriptionProducts.isNotEmpty)
                    Text(
                      "Subscribe",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  if (subscriptionProducts.isNotEmpty) const Divider(),
                  if (subscriptionProducts.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: subscriptionProducts.length,
                      itemBuilder: (context, index) {
                        return ContributeListItem(
                          product: subscriptionProducts[index],
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
