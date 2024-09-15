import 'dart:async';

import 'package:maplibre_gl/maplibre_gl.dart';

import 'fwd_marker_animation_event.dart';
import 'fwd_marker_animation_state.dart';

class FwdMarkerAnimationController {
  StreamController<FwdMarkerAnimationEvent> streamController = StreamController<FwdMarkerAnimationEvent>();

  FwdMarkerAnimationState? state;

  void _addEvent(FwdMarkerAnimationEvent event) {
    if (streamController.isClosed) {
      return;
    }
    streamController.add(event);
  }

  void animate({
    required LatLng point,
    required Duration duration,
  }) {
    _addEvent(FwdMarkerAnimationEvent.animate(point: point, duration: duration));
  }
}
