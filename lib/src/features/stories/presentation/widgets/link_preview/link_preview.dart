import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks/src/extensions/context_extension.dart';
import 'package:hooks/src/features/common/domain/assets.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/widgets/link_preview/widgets/link_view.dart';

class LinkPreview extends StatefulWidget {
  const LinkPreview({
    required this.link,
    required this.story,
    required this.onTap,
    required this.showMetadata,
    required this.showUrl,
    required this.titleStyle,
    super.key,
    this.cache = const Duration(days: 30),
    this.showMultimedia = true,
    this.backgroundColor = const Color.fromRGBO(235, 235, 235, 1),
    this.bodyMaxLines = 3,
    this.bodyTextOverflow = TextOverflow.ellipsis,
    this.placeholderWidget,
    this.errorWidget,
    this.errorBody,
    this.errorImage,
    this.errorTitle,
    this.borderRadius,
    this.boxShadow,
    this.removeElevation = false,
  });

  final Story story;
  final VoidCallback onTap;

  /// Web address (Url that need to be parsed)
  /// For IOS & Web, only HTTP and HTTPS are support
  /// For Android, all urls are supported
  final String link;

  /// Customize background colour
  /// Defaults to `Color.fromRGBO(235, 235, 235, 1)`
  final Color? backgroundColor;

  /// Widget that need to be shown when
  /// plugin is trying to fetch metadata
  /// If not given anything then default one will be shown
  final Widget? placeholderWidget;

  /// Widget that need to be shown if something goes wrong
  /// Defaults to plain container with given background colour
  /// If the issue is know then we will show customized UI
  /// Other options of error params are used
  final Widget? errorWidget;

  /// Title that need to be shown if something goes wrong
  /// Defaults to `Something went wrong!`
  final String? errorTitle;

  /// Body that need to be shown if something goes wrong
  /// Defaults to `Oops! Unable to parse the url.
  /// We have sent feedback to our developers & we will
  /// try to fix this in our next release. Thanks!`
  final String? errorBody;

  /// Image that will be shown if something goes wrong
  /// & when multimedia enabled & no meta data is available
  /// Defaults to `A semi-soccer ball image that looks like crying`
  final String? errorImage;

  /// Give the overflow type for body text (Description)
  /// Defaults to `TextOverflow.ellipsis`
  final TextOverflow bodyTextOverflow;

  /// Give the limit to body text (Description)
  /// Defaults to `3`
  final int bodyMaxLines;

  /// Cache result time, default cache `30 days`
  /// Works only for IOS & not for android
  final Duration cache;

  /// Customize body `TextStyle`
  final TextStyle titleStyle;

  /// Show or Hide image if available defaults to `true`
  final bool showMultimedia;

  /// BorderRadius for the card. Defaults to `12`
  final double? borderRadius;

  /// To remove the card elevation set it to `true`
  /// Default value is `false`
  final bool removeElevation;

  /// Box shadow for the card. Defaults to
  /// `[BoxShadow(blurRadius: 3, color: Palette.grey)]`
  final List<BoxShadow>? boxShadow;

  final bool showMetadata;
  final bool showUrl;

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  InfoBase? _info;
  String? _errorTitle;
  String? _errorBody;
  bool _loading = false;

  @override
  void initState() {
    _errorTitle = widget.errorTitle ?? Constants.errorMessage;
    _errorBody = widget.errorBody ?? 'Oops! Unable to parse the url.';

    _loading = true;
    _getInfo();

    super.initState();
  }

  Future<void> _getInfo() async {
    _info = await WebAnalyzer.getInfo(
      story: widget.story,
      cache: widget.cache,
    );

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildLinkContainer(
    double height, {
    String? title = '',
    String? desc = '',
    String? imageUri = '',
    bool isIcon = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? 12,
        ),
        boxShadow: widget.removeElevation
            ? <BoxShadow>[]
            : widget.boxShadow ?? <BoxShadow>[const BoxShadow(blurRadius: 3, color: AppColors.grey4)],
      ),
      height: height,
      child: LinkView(
        key: widget.key ?? Key(widget.link),
        metadata: widget.story.simpleMetadata,
        timeAgo: widget.story.timeAgo,
        url: widget.link,
        readableUrl: widget.story.readableUrl,
        title: widget.story.title,
        description: desc ?? title ?? 'no comment yet.',
        imageUri: imageUri,
        imagePath: Assets.hackerNewsLogoPath,
        onTap: widget.onTap,
        titleTextStyle: widget.titleStyle,
        bodyTextOverflow: widget.bodyTextOverflow,
        bodyMaxLines: widget.bodyMaxLines,
        showMultiMedia: widget.showMultimedia,
        isIcon: isIcon,
        isJob: widget.story.isJob,
        bgColor: widget.backgroundColor,
        radius: widget.borderRadius ?? 12,
        showMetadata: widget.showMetadata,
        showUrl: widget.showUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget = widget.placeholderWidget ??
        Container(
          height: context.storyTileHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
            color: AppColors.grey2,
          ),
          alignment: Alignment.center,
          child: const Text('Fetching data...'),
        );

    Widget loadedWidget;

    final info = _info as WebInfo?;
    loadedWidget = _info == null
        ? _buildLinkContainer(
            context.storyTileHeight,
            title: _errorTitle,
            desc: _errorBody,
            imageUri: null,
          )
        : _buildLinkContainer(
            context.storyTileHeight,
            title: _errorTitle,
            desc: WebAnalyzer.isNotEmpty(info!.description)
                ? info.description
                : _errorBody,
            imageUri: widget.showMultimedia
                ? (WebAnalyzer.isNotEmpty(info.image) ? info.image
                : WebAnalyzer.isNotEmpty(info.icon) ? info.icon : null)
                : null,
            isIcon: !WebAnalyzer.isNotEmpty(info.image),
          );

    return AnimatedCrossFade(
      firstChild: loadingWidget,
      secondChild: loadedWidget,
      crossFadeState:
          _loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 500),
    );
  }
}
