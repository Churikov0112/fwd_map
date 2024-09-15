import 'dart:math' show Point;

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'fwd_id/fwd_id.dart';
import 'fwd_map_controller.dart' show FwdMapController;
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_widget.dart' show FwdMarkerAnimationWidget;

export 'dart:math' show Point;

export 'package:maplibre_gl/maplibre_gl.dart' show CameraPosition, LatLng, MinMaxZoomPreference;

export 'fwd_map_controller.dart' show FwdMapController;
export 'fwd_marker/dynamic/fwd_dynamic_marker.dart' show FwdDynamicMarker;
export 'fwd_marker/static/fwd_static_marker.dart' show FwdStaticMarker;
export 'fwd_polygon/fwd_polygon.dart' show FwdPolygon;
export 'fwd_polyline/fwd_polyline.dart' show FwdPolyline;

class FwdMap extends StatefulWidget {
  const FwdMap({
    required this.initialCameraPosition,
    required this.zoomPreference,
    required this.onFwdMapCreated,
    this.trackCameraPosition = true,
    this.onMapLongClick,
    this.onCameraIdle,
    this.onStyleLoadedCallback,
    this.styleString,
    Key? key,
  }) : super(key: key);

  final String? styleString;
  final CameraPosition initialCameraPosition;
  final MinMaxZoomPreference zoomPreference;
  final bool trackCameraPosition;

  final Function(FwdMapController fwdMapController) onFwdMapCreated;
  final Function(Point<double> point, LatLng coordinates)? onMapLongClick;
  final Function()? onCameraIdle;
  final Function()? onStyleLoadedCallback;

  @override
  State<FwdMap> createState() => _FwdMapState();
}

class _FwdMapState extends State<FwdMap> {
  late FwdMapController fwdMapController;

  Map<FwdId, FwdMarkerAnimationWidget> _dynamicMarkerAnimationWidgets = {};
  Map<FwdId, FwdMarkerAnimationWidget> _staticMarkerAnimationWidgets = {};

  void _updateDynamicMarkerWidgets(Map<FwdId, FwdMarkerAnimationWidget> newMarkerAnimationWidgets) async {
    _dynamicMarkerAnimationWidgets = newMarkerAnimationWidgets;
    setState(() {});
  }

  void _updateStaticMarkerAnimationWidgets(Map<FwdId, FwdMarkerAnimationWidget> newStaticMarkerAnimationWidgets) async {
    _staticMarkerAnimationWidgets = newStaticMarkerAnimationWidgets;
    setState(() {});
  }

  void _onMapCreated(MapLibreMapController maplibreMapController) {
    fwdMapController = FwdMapController(
      maplibreMapController,
      _updateDynamicMarkerWidgets,
      _updateStaticMarkerAnimationWidgets,
    );
    widget.onFwdMapCreated(fwdMapController);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapLibreMap(
          styleString: widget.styleString ?? MapLibreStyles.demo,
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          onMapLongClick: widget.onMapLongClick,
          onCameraIdle: widget.onCameraIdle,
          onStyleLoadedCallback: widget.onStyleLoadedCallback,
          initialCameraPosition: widget.initialCameraPosition,
          minMaxZoomPreference: widget.zoomPreference,
        ),
        if (_dynamicMarkerAnimationWidgets.isNotEmpty) ..._dynamicMarkerAnimationWidgets.values.toList(),
        if (_staticMarkerAnimationWidgets.isNotEmpty) ..._staticMarkerAnimationWidgets.values.toList(),
      ],
    );
  }
}
