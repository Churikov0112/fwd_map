import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

class Polylines extends StatefulWidget {
  const Polylines({
    required this.fwdMapController,
    super.key,
  });

  final FwdMapController fwdMapController;

  @override
  State<Polylines> createState() => _PolylinesState();
}

class _PolylinesState extends State<Polylines> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final random = Random();

      await widget.fwdMapController.addPolyline(
        FwdPolyline(
          id: FwdId.generateFromRandomUUID(),
          geometry: [
            for (var i = 0; i < 10; i++) LatLng(59 + random.nextDouble(), 30 + random.nextDouble()),
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
