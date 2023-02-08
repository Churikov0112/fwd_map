import 'dart:math' show Point;

import 'package:flutter/widgets.dart' show StatefulWidget, State, BuildContext, Widget, Stack, Key;
import 'package:fwd_minimal_sdk/fwd_minimal_sdk.dart';
import 'package:maplibre_gl/mapbox_gl.dart'
    show CameraPosition, LatLng, MaplibreMap, MaplibreMapController, MinMaxZoomPreference;

import 'fwd_map_controller.dart' show FwdMapController;
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_widget.dart' show FwdMarkerAnimationWidget;

export 'package:maplibre_gl/mapbox_gl.dart' show LatLng, CameraPosition, CameraUpdate;

export 'fwd_map_controller.dart' show FwdMapController;
export 'fwd_marker/dynamic/fwd_dynamic_marker.dart' show FwdDynamicMarker;
export 'fwd_marker/static/fwd_static_marker.dart' show FwdStaticMarker;
export 'fwd_polygon/fwd_polygon.dart' show FwdPolygon;
export 'fwd_polyline/fwd_polyline.dart' show FwdPolyline;

class FwdMap extends StatefulWidget {
  const FwdMap({
    required this.initialCameraPosition,
    required this.trackCameraPosition,
    required this.onFwdMapCreated,
    required this.onMapLongClick,
    required this.onCameraIdle,
    required this.onStyleLoadedCallback,
    this.maxZoom,
    this.minZoom,
    this.styleString,
    Key? key,
  }) : super(key: key);

  final String? styleString;
  final CameraPosition initialCameraPosition;
  final bool trackCameraPosition;

  final Function(FwdMapController fwdMapController) onFwdMapCreated;
  final Function(Point<double> point, LatLng coordinates) onMapLongClick;
  final Function() onCameraIdle;
  final Function() onStyleLoadedCallback;

  final double? minZoom;
  final double? maxZoom;

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

  void _onMapCreated(MaplibreMapController maplibreMapController) {
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
        MaplibreMap(
          styleString: widget.styleString,
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          onMapLongClick: widget.onMapLongClick,
          onCameraIdle: widget.onCameraIdle,
          onStyleLoadedCallback: widget.onStyleLoadedCallback,
          initialCameraPosition: widget.initialCameraPosition,
          minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
        ),
        if (_dynamicMarkerAnimationWidgets.isNotEmpty) ..._dynamicMarkerAnimationWidgets.values.toList(),
        if (_staticMarkerAnimationWidgets.isNotEmpty) ..._staticMarkerAnimationWidgets.values.toList(),
      ],
    );
  }
}
