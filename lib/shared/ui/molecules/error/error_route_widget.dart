import 'package:nextoffice/shared/extensions/spacing.dart';
import 'package:flutter/material.dart';

import 'package:nextoffice/shared/constants/assects_const.dart';
import 'package:nextoffice/shared/constants/color_const.dart';
import 'package:nextoffice/navigation/custom_router/custom_route.dart';
import 'package:nextoffice/navigation/router_name.dart';
import 'package:nextoffice/shared/utils/text_utils.dart';
import 'package:nextoffice/shared/ui/atoms/buttons/custom_button.dart';
import 'package:nextoffice/shared/ui/atoms/images/custom_image.dart';
import 'package:nextoffice/shared/ui/atoms/text/custom_text.dart';

class ErrorRouteWidget extends StatelessWidget {
  const ErrorRouteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: CustomText(TextUtils.notFound,
            color: ColorConst.primaryDark, size: 20),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomAssetImageView(
                path: AssetsConst.pageNotFound,
                height: 200,
                width: 200,
              ),
              8.ph,
              CustomText(
                'Oops! Something went wrong...',
                color: ColorConst.primaryDark,
                size: 20,
              ),
              8.ph,
              CustomText(
                '404',
                color: ColorConst.primaryDark,
                size: 50,
              ),
              8.ph,
              CustomText(
                'Page Not Found',
                color: ColorConst.primaryDark,
                size: 20,
              ),
              12.ph,
              CustomGOEButton(
                borderRadius: BorderRadius.circular(6),
                backGroundColor: Colors.blueAccent,
                onPressed: () {
                  CustomRoute.clearAndNavigateName(RouteName.initialView);
                },
                child: const CustomText(
                  "Back to Home",
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
