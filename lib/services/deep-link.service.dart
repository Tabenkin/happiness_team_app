import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:happiness_team_app/models/win.model.dart';

class DeepLinkService {
  static Future<String> createDeepLink(Win win) async {

    var imageurl = "https://firebasestorage.googleapis.com/v0/b/happinessteamwinningwheel.appspot.com/o/public%2Fhappiness_logo.jpg?alt=media&token=3b16c7c1-0902-42d1-a7d4-1f33c486b44c";

    if(win.images.isNotEmpty) {
      imageurl = win.images.first.mediaHref ?? "https://i0.wp.com/myhappiness.team/wp-content/uploads/2022/06/HT_banner_Final-clear.png?fit=829%2C189&ssl=1";
    }

    final buo = BranchUniversalObject(
      canonicalIdentifier: win.id!,
      title: win.formattedDate,
      contentDescription: win.notes,
      imageUrl: imageurl,
    );

    final linkProperties = BranchLinkProperties(
      channel: "Happiness Team",
      tags: ["win", win.id!],
    );

    linkProperties.addControlParam('winId', win.id!);
    linkProperties.addControlParam('event', 'view_shared_win');

    var response = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: linkProperties);

    print(response.result);

    if (response.result == null) {
      throw Exception("Failed to create deep link");
    }

    return response.result;
  }
}
