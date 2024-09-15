import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map/fwd_map.dart';

class DynamicMarkers extends StatefulWidget {
  const DynamicMarkers({
    required this.fwdMapController,
    super.key,
  });

  final FwdMapController fwdMapController;

  @override
  State<DynamicMarkers> createState() => _DynamicMarkersState();
}

class _DynamicMarkersState extends State<DynamicMarkers> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final random = Random();
      for (var i = 0; i < 50; i++) {
        await widget.fwdMapController.addDynamicMarker(
          FwdDynamicMarker(
            id: FwdId.generateFromRandomUUID(),
            coordinate: LatLng(59 + random.nextDouble(), 30 + random.nextDouble()),
            child: Image.network(
              "https://media.tenor.com/AjnmzDeQiKUAAAAM/dance-happy-dance.gif",
              height: 50,
              width: 50,
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
