import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fwd_map/fwd_map/fwd_id/fwd_id.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class FwdDynamicMarkerWidget extends StatefulWidget {
  const FwdDynamicMarkerWidget({
    required this.maplibreMapController,
    required this.id,
    required this.coordinate,
    required this.initialPosition,
    required this.initialBearing,
    this.onMarkerTap,
    required this.child,
    Key? key,
  }) : super(key: key);

  final FwdId id;
  final MapLibreMapController maplibreMapController;
  final Function(FwdId, LatLng, Point<num>?)? onMarkerTap;
  final LatLng coordinate;
  final Point initialPosition;
  final double initialBearing;
  final Widget child;

  @override
  State<FwdDynamicMarkerWidget> createState() => FwdDynamicMarkerWidgetState();
}

class FwdDynamicMarkerWidgetState extends State<FwdDynamicMarkerWidget> {
  late Point _position;
  late double _bearing;

  Future<void> _cameraMovingListener() async {
    if (widget.maplibreMapController.isCameraMoving) {
      await calculatePosition();
      setState(() {});
    }
  }

  Future<void> _bearingListener() async {
    if (widget.maplibreMapController.cameraPosition?.bearing != _bearing) {
      if (widget.maplibreMapController.cameraPosition?.bearing != null) {
        _bearing = widget.initialBearing + widget.maplibreMapController.cameraPosition!.bearing;
        setState(() {});
      }
    }
  }

  Future<void> calculatePosition() async {
    _position = await widget.maplibreMapController.toScreenLocation(widget.coordinate);
  }

  @override
  void initState() {
    _position = widget.initialPosition;
    _bearing = widget.initialBearing;
    widget.maplibreMapController.addListener(_cameraMovingListener);
    widget.maplibreMapController.addListener(_bearingListener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FwdDynamicMarkerWidget oldWidget) {
    if (oldWidget.coordinate != widget.coordinate) {
      _position = widget.initialPosition;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.maplibreMapController.removeListener(_cameraMovingListener);
    widget.maplibreMapController.removeListener(_bearingListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_position == null) {
    //   return const SizedBox.shrink();
    // }

    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    // print(_bearing);

    return Positioned(
      left: _position.x / ratio - 50 / 2,
      top: _position.y / ratio - 50 / 2,
      child: Transform.rotate(
        angle: -_bearing * pi / 180,
        child: GestureDetector(
          onTap: () {
            if (widget.onMarkerTap != null) {
              widget.onMarkerTap!(widget.id, widget.coordinate, _position);
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
