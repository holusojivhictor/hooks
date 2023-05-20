import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/styles.dart';
import 'package:shimmer/shimmer.dart';

class LinkPreviewPlaceholder extends StatelessWidget {
  const LinkPreviewPlaceholder({required this.height, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: SizedBox(
        height: height,
        child: Shimmer.fromColors(
          baseColor: AppColors.grey3,
          highlightColor: AppColors.grey1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  right: 5,
                  bottom: 5,
                  top: 5,
                ),
                child: ClipRRect(
                  borderRadius: Styles.defaultCardBorderRadius,
                  child: Container(
                    height: height,
                    width: height,
                    color: AppColors.white,
                  ),
                ),
              ),
              const Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 4,
                    top: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ContainerWithRadius(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      ContainerWithRadius(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      ContainerWithRadius(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      ContainerWithRadius(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      ContainerWithRadius(
                        width: 40,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ContainerWithRadius extends StatelessWidget {
  const ContainerWithRadius({
    super.key,
    this.width = double.infinity,
    this.height = 10,
    this.color = AppColors.white,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(2)),
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}
