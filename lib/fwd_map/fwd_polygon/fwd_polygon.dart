import 'dart:math';
import 'dart:ui';
import 'package:fwd_minimal_sdk/fwd_minimal_sdk.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class FwdPolygon {
  final FwdId id;
  final List<List<LatLng>> geometry;
  final double? borderThickness;
  final Color? fillColor;
  final Color? borderColor;
  final Function(FwdId, Point<double>, LatLng)? onTap;

  FwdPolygon({
    required this.id,
    required this.geometry,
    this.borderThickness,
    this.borderColor,
    this.fillColor,
    this.onTap,
  });
}
