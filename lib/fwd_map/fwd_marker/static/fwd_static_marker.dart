import 'dart:math';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/widgets.dart' show Widget;
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../fwd_id/fwd_id.dart';
import '../../fwd_map_helpers/fwd_map_marker_helper.dart';

enum MarkerAnchor { bottom, center, top }

class FwdStaticMarker {
  final FwdId id;
  final LatLng coordinate;
  final bool rotate;
  final double bearing;
  final void Function(FwdId, Point<double>, LatLng) onTap;

  final Uint8List bytes;

  final MarkerAnchor anchor;

  const FwdStaticMarker._(
    this.id,
    this.coordinate,
    this.onTap,
    this.bytes,
    this.rotate,
    this.bearing,
    this.anchor,
  );

  static Future<FwdStaticMarker> fromWidget({
    required FwdId id,
    required LatLng coordinate,
    required void Function(FwdId, Point<double>, LatLng) onTap,
    required Widget child,
    bool rotate = true,
    double bearing = 0.0,
    Duration? creatingImageDelay,
    String? cacheKey,
    MarkerAnchor anchor = MarkerAnchor.center,
  }) async {
    final widgetBytes = await FwdMapMarkerHelper.widgetToBytes(child, delay: creatingImageDelay, cacheKey: cacheKey);
    return FwdStaticMarker._(id, coordinate, onTap, widgetBytes, rotate, bearing, anchor);
  }

  static Future<FwdStaticMarker> fromImageAsset({
    required FwdId id,
    required LatLng coordinate,
    required void Function(FwdId, Point<double>, LatLng) onTap,
    required String imageAssetPath,
    bool rotate = true,
    double bearing = 0.0,
    MarkerAnchor anchor = MarkerAnchor.center,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageAssetToBytes(imageAssetPath);
    return FwdStaticMarker._(id, coordinate, onTap, imageBytes, rotate, bearing, anchor);
  }

  static Future<FwdStaticMarker> fromImageNetwork({
    required FwdId id,
    required LatLng coordinate,
    required void Function(FwdId, Point<double>, LatLng) onTap,
    required String imageUrl,
    bool rotate = true,
    double bearing = 0.0,
    MarkerAnchor anchor = MarkerAnchor.center,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageNetworkToBytes(imageUrl);
    return FwdStaticMarker._(id, coordinate, onTap, imageBytes, rotate, bearing, anchor);
  }
}
