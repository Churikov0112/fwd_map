import 'dart:math';
import 'dart:ui';
import 'package:fwd_minimal_sdk/fwd_minimal_sdk.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class FwdPolyline {
  final FwdId id;
  final List<LatLng> geometry;
  final double? thickness;
  final Color? color;
  final Function(FwdId, Point<double>, LatLng)? onTap;

  FwdPolyline({
    required this.id,
    required this.geometry,
    this.thickness,
    this.color,
    this.onTap,
  });
}
