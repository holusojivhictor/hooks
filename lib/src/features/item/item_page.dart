import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/utils/utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({
    required this.item,
    required this.parentComments,
    super.key,
  });

  final Item item;
  final List<Comment> parentComments;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> with RouteAware {
  static const Duration _storyLinkTapThrottleDelay = Duration(seconds: 2);

  final TextEditingController commentEditingController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final Throttle storyLinkTapThrottle = Throttle(
    delay: _storyLinkTapThrottleDelay,
  );
  final GlobalKey fontSizeIconButtonKey = GlobalKey();

  @override
  void didPop() {
    // TODO(morpheus): Update dipPop
    super.didPop();
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);

      if (route == null) return;

      getIt<RouteObserver<ModalRoute<dynamic>>>().subscribe(this, route);
    });

    // TODO(morpheus): Add edit cubit state text
    commentEditingController.text = '';
  }

  @override
  void dispose() {
    commentEditingController.dispose();
    storyLinkTapThrottle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
