import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

class StaticMarkersFromWidget extends StatefulWidget {
  const StaticMarkersFromWidget({
    required this.fwdMapController,
    super.key,
  });

  final FwdMapController fwdMapController;

  @override
  State<StaticMarkersFromWidget> createState() => _StaticMarkersFromWidgetState();
}

class _StaticMarkersFromWidgetState extends State<StaticMarkersFromWidget> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final random = Random();
      for (var i = 0; i < 50; i++) {
        await widget.fwdMapController.addStaticMarker(
          await FwdStaticMarker.fromWidget(
            id: FwdId.generateFromRandomUUID(),
            creatingImageDelay: const Duration(milliseconds: 100),
            coordinate: LatLng(59 + random.nextDouble(), 30 + random.nextDouble()),
            onTap: (fwdId, coord, point) {},
            child: Container(
              height: 50,
              width: 50,
              color: Colors.red,
            ),
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
