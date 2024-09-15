import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

class StaticMarkersFromAssetImage extends StatefulWidget {
  const StaticMarkersFromAssetImage({
    required this.fwdMapController,
    super.key,
  });

  final FwdMapController fwdMapController;

  @override
  State<StaticMarkersFromAssetImage> createState() => _StaticMarkersFromAssetImageState();
}

class _StaticMarkersFromAssetImageState extends State<StaticMarkersFromAssetImage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final random = Random();
      for (var i = 0; i < 50; i++) {
        await widget.fwdMapController.addStaticMarker(
          await FwdStaticMarker.fromImageAsset(
            id: FwdId.generateFromRandomUUID(),
            coordinate: LatLng(59 + random.nextDouble(), 30 + random.nextDouble()),
            onTap: (fwdId, coord, point) {},
            imageAssetPath: "assets/raster/test_image.png",
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
