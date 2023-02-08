import 'package:maplibre_gl/mapbox_gl.dart';

class FwdMarkerAnimationEvent {
  final LatLng? point;
  final Duration? duration;
  final FwdMarkerAnimationAction action;

  FwdMarkerAnimationEvent.animate({
    this.point,
    this.duration,
  }) : action = FwdMarkerAnimationAction.animate;

  // FwdMarkerAnimationEvent.remove()
  //     : point = null,
  //       duration = null,
  //       action = FwdStaticMarkerAnimationAction.remove;

  // FwdMarkerAnimationEvent.teleport({
  //   this.point,
  // })  : duration = null,
  //       action = FwdStaticMarkerAnimationAction.teleport;
}

enum FwdMarkerAnimationAction {
  animate,
  // remove,
  // teleport,
}
