import 'package:maplibre_gl/maplibre_gl.dart';

class FwdMarkerAnimationEvent {
  final LatLng? point;
  final Duration? duration;
  final FwdMarkerAnimationAction action;

  FwdMarkerAnimationEvent.animate({
    this.point,
    this.duration,
  }) : action = FwdMarkerAnimationAction.animate;
}

enum FwdMarkerAnimationAction { animate }
