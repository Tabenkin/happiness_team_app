import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:happiness_team_app/helpers/dialog.helpers.dart';
import 'package:happiness_team_app/models/product.model.dart';
import 'package:happiness_team_app/router/happiness_router.gr.dart';
import 'package:happiness_team_app/services/payments.service.dart';
import 'package:happiness_team_app/widgets/Base/base_button.widget.dart';
import 'package:happiness_team_app/widgets/Base/base_text.widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ContributeListItem extends StatefulWidget {
  final Product product;

  const ContributeListItem({
    required this.product,
    super.key,
  });

  @override
  State<ContributeListItem> createState() => _ContributeListItemState();
}

class _ContributeListItemState extends State<ContributeListItem> {
  bool _isPurchasing = false;

  _purchasePackage(Package storePackage) async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      await PaymentsService.purchasePackage(storePackage);

      AutoRouter.of(context).replace(const ContributionThankYouRoute());
    } catch (error) {
      setState(() {
        _isPurchasing = false;
      });

      DialogHelper.showSimpleErrorToast(
          context, "Oops! Something went wrong. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var storePackage = widget.product.storePackage;

    if (storePackage == null) return const SizedBox();

    var storeProduct = storePackage.storeProduct;

    var suffix =
        widget.product.type == ProductType.subscription ? "/month" : "";

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      title: BaseText(
        widget.product.label,
        style: Theme.of(context).textTheme.headlineSmall,
        maxTextScale: 1.0,
      ),
      trailing: SizedBox(
        width: 160,
        child: BaseButton(
          width: double.infinity,
          onPressed: () => _purchasePackage(storePackage),
          theme: BaseButtonTheme.secondary,
          showSpinner: _isPurchasing,
          child: BaseText(
            "${storeProduct.priceString}$suffix",
            maxTextScale: 1.0,
          ),
        ),
      ),
    );
  }
}
