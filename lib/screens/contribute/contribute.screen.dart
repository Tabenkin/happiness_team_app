import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/components/contribute_list/contribute_list_item.widget.dart';
import 'package:happiness_team_app/models/product.model.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/services/payments.service.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:happiness_team_app/widgets/Base/base_text_button.widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

@RoutePage()
class ContributeScreen extends StatefulWidget {
  const ContributeScreen({
    super.key,
  });

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  _viewPrivacyPolicy() {
    context.router.push(const PrivacyPolicyRoute());
  }

  _viewTermsOfUSe() async {
    const url =
        "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/";

    await launchUrlString(url);
  }

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
        title: const BaseText('Support Us'),
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
                  BaseText(
                    "Support the Happiness Team in our mission to make the world a happier place",
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxTextScale: 1.0,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  BaseText(
                    "One-time purchases",
                    style: Theme.of(context).textTheme.headlineMedium,
                    maxTextScale: 1.0,
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: purchaseProducts.length,
                    itemBuilder: (context, index) {
                      return ContributeListItem(
                        product: purchaseProducts[index],
                      );
                    },
                  ),
                  if (subscriptionProducts.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseText(
                          "Subscribe",
                          style: Theme.of(context).textTheme.headlineMedium,
                          maxTextScale: 1.0,
                        ),
                        BaseText(
                          "Make a monthly recurring contribution to the Happiness Team. Cancel anytime.",
                          maxTextScale: 1.0,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      ],
                    ),
                  if (subscriptionProducts.isNotEmpty) const Divider(),
                  if (subscriptionProducts.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: subscriptionProducts.length,
                      itemBuilder: (context, index) {
                        return ContributeListItem(
                          product: subscriptionProducts[index],
                        );
                      },
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BaseTextButton(
                        onPressed: _viewPrivacyPolicy,
                        child: BaseText(
                          "Privacy Policy",
                          maxTextScale: 1.0,
                        ),
                      ),
                      BaseText(
                        "|",
                        maxTextScale: 1.0,
                      ),
                      TextButton(
                        onPressed: _viewTermsOfUSe,
                        child: BaseText(
                          "Terms of Use (EULA)",
                          maxTextScale: 1.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.0,
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
