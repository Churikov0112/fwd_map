import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

class StaticMarkersFromNetworkImage extends StatefulWidget {
  const StaticMarkersFromNetworkImage({
    required this.fwdMapController,
    super.key,
  });

  final FwdMapController fwdMapController;

  @override
  State<StaticMarkersFromNetworkImage> createState() => _StaticMarkersFromNetworkImageState();
}

class _StaticMarkersFromNetworkImageState extends State<StaticMarkersFromNetworkImage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final random = Random();
      for (var i = 0; i < 50; i++) {
        await widget.fwdMapController.addStaticMarker(
          await FwdStaticMarker.fromImageNetwork(
            id: FwdId.generateFromRandomUUID(),
            coordinate: LatLng(59 + random.nextDouble(), 30 + random.nextDouble()),
            onTap: (fwdId, coord, point) {},
            imageUrl: "https://media.tenor.com/AjnmzDeQiKUAAAAM/dance-happy-dance.gif",
          ),
        );
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
