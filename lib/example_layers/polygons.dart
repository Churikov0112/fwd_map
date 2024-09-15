import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

class Polygons extends StatefulWidget {
  const Polygons({
    required this.fwdMapController,
    super.key,
  });

  final FwdMapController fwdMapController;

  @override
  State<Polygons> createState() => _PolygonsState();
}

class _PolygonsState extends State<Polygons> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final random = Random();

      await widget.fwdMapController.addPolygon(
        FwdPolygon(
          id: FwdId.generateFromRandomUUID(),
          geometry: [
            [
              for (var i = 0; i < 4; i++) LatLng(59 + random.nextDouble(), 30 + random.nextDouble()),
            ],
          ],
        ),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
