import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:fwd_minimal_sdk/fwd_minimal_sdk.dart';
import 'package:location/location.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'fwd_map_helpers/fwd_geo_json_helper.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_controller.dart';
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_widget.dart';
import 'fwd_marker/static/fwd_static_marker.dart';
import 'fwd_polygon/fwd_polygon.dart';
import 'fwd_polyline/fwd_polyline.dart';

class FwdMapController {
  final MaplibreMapController _maplibreMapController;

  Map<FwdId,
          Tuple5<FwdStaticMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget, Map<String, dynamic>, LatLng>>
      // ignore: prefer_final_fields
      _staticMarkers = {};
  final Function(Map<FwdId, FwdMarkerAnimationWidget>) _updateStaticMarkerAnimationWidgetsCallback;

  // ignore: prefer_final_fields
  Map<FwdId, Tuple4<FwdDynamicMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget, LatLng>> _dynamicMarkers =
      {};
  final Function(Map<FwdId, FwdMarkerAnimationWidget>) _updateDynamicMarkerWidgetsCallback;

  // ignore: prefer_final_fields
  Map<FwdId, Tuple2<FwdPolyline, Line>> _polylines = {};

  // polygon, line, fill
  // ignore: prefer_final_fields
  Map<FwdId, Tuple3<FwdPolygon, Fill, Line>> _polygons = {};

  CameraPosition? get cameraPosition => _maplibreMapController.cameraPosition;

  FwdStaticMarker? getFwdStaticMarkerById(FwdId id) {
    if (_staticMarkers.keys.contains(id)) return _staticMarkers[id]!.item1;
    return null;
  }

  FwdDynamicMarker? getFwdDynamicMarkerById(FwdId id) {
    if (_dynamicMarkers.keys.contains(id)) return _dynamicMarkers[id]!.item1;
    return null;
  }

  FwdPolygon? getFwdPolygonById(FwdId id) {
    if (_polygons.keys.contains(id)) return _polygons[id]!.item1;
    return null;
  }

  FwdPolyline? getFwdPolylineById(FwdId id) {
    if (_polylines.keys.contains(id)) return _polylines[id]!.item1;
    return null;
  }

  FwdMapController(
    this._maplibreMapController,
    this._updateDynamicMarkerWidgetsCallback,
    this._updateStaticMarkerAnimationWidgetsCallback,
  ) {
    _maplibreMapController.onFeatureTapped.add(_onFeatureTapped);
  }

  void addListener(Function() listener) {
    _maplibreMapController.addListener(listener);
  }

  void removeListener(Function() listener) {
    _maplibreMapController.removeListener(listener);
  }

  void _onFeatureTapped(dynamic featureId, Point<double> position, LatLng coordinate) {
    final FwdId markerIdFromPointFeatureId = FwdGeoJsonHelper.markerIdFromPointFeatureId(featureId);
    final FwdId polylineIdFromPolylineFeatureId = FwdGeoJsonHelper.markerIdFromPolylineFeatureId(featureId);
    final FwdId polygonIdFromPolygonFeatureId = FwdGeoJsonHelper.markerIdFromPolygonFeatureId(featureId);

    if (_staticMarkers.keys.contains(markerIdFromPointFeatureId)) {
      _staticMarkers[markerIdFromPointFeatureId]?.item1.onTap.call(markerIdFromPointFeatureId, position, coordinate);
      return;
    }
    if (_polylines.keys.contains(polylineIdFromPolylineFeatureId)) {
      _polylines[polylineIdFromPolylineFeatureId]
          ?.item1
          .onTap
          ?.call(polygonIdFromPolygonFeatureId, position, coordinate);
      return;
    }
    if (_polygons.keys.contains(polygonIdFromPolygonFeatureId)) {
      _polygons[polygonIdFromPolygonFeatureId]?.item1.onTap?.call(polygonIdFromPolygonFeatureId, position, coordinate);
      return;
    }
  }

  Future<void> addStaticMarker(FwdStaticMarker fwdStaticMarker) async {
    await _deleteStaticMarkerById(fwdStaticMarker.id);

    await _maplibreMapController.addImage(
      FwdGeoJsonHelper.getImageId(fwdStaticMarker.id),
      fwdStaticMarker.bytes,
    );

    final geoJson = FwdGeoJsonHelper.pointGeoJson(
      staticMarkerId: fwdStaticMarker.id,
      bearing: fwdStaticMarker.bearing,
      geometry: fwdStaticMarker.coordinate,
    );

    await _maplibreMapController.addGeoJsonSource(
      FwdGeoJsonHelper.pointGeoJsonSourceId(fwdStaticMarker.id),
      geoJson,
    );

    await _maplibreMapController.addSymbolLayer(
      FwdGeoJsonHelper.pointGeoJsonSourceId(fwdStaticMarker.id),
      FwdGeoJsonHelper.symbolLayerId(fwdStaticMarker.id),
      SymbolLayerProperties(
        iconRotationAlignment: fwdStaticMarker.rotate ? "auto" : "map",
        iconImage: FwdGeoJsonHelper.getImageId(fwdStaticMarker.id),
        iconAllowOverlap: true,
        iconRotate: fwdStaticMarker.bearing,
        iconAnchor: fwdStaticMarker.anchor.name,
      ),
    );

    FwdMarkerAnimationController fwdMarkerAnimationController = FwdMarkerAnimationController();

    FwdMarkerAnimationWidget fwdStaticMarkerAnimationWidget = FwdMarkerAnimationWidget.fromGeoJson(
      geoJson: geoJson,
      maplibreMapController: _maplibreMapController,
      fwdMarkerAnimationController: fwdMarkerAnimationController,
      rotate: fwdStaticMarker.rotate,
      initialBearing: fwdStaticMarker.bearing,
      key: UniqueKey(),
    );

    _staticMarkers[fwdStaticMarker.id] = Tuple5(
      fwdStaticMarker,
      fwdMarkerAnimationController,
      fwdStaticMarkerAnimationWidget,
      geoJson,
      fwdStaticMarker.coordinate,
    );

    // ниже - коллбэк

    final Map<FwdId, FwdMarkerAnimationWidget> animationWidgetsForCallback = {};

    _staticMarkers.forEach((fwdId, tuple4) {
      animationWidgetsForCallback[fwdId] = tuple4.item3;
    });

    _updateStaticMarkerAnimationWidgetsCallback(animationWidgetsForCallback);
  }

  /// УКАЗЫВАЙТЕ ЛИБО newWidgetChild, ЛИБО newImageAssetPath, ЛИБО newImageNetworkUrl
  ///
  /// НИ В КОЕМ СЛУЧАЕ НЕ ВСЁ ВМЕСТЕ
  Future<void> updateStaticMarker({
    required FwdId markerId,
    LatLng? newCoordinate,
    double? newBearing,
    Widget? newWidgetChild,
    String? newImageAssetPath,
    String? newImageNetworkUrl,
    Duration? updatingImageDelay,
    String? cacheKey,
    MarkerAnchor? newAnchor,
  }) async {
    // assert((newWidgetChild != null && newImageAssetPath == null && newImageNetworkUrl == null) ||
    //     (newWidgetChild == null && newImageAssetPath != null && newImageNetworkUrl == null) ||
    //     (newWidgetChild == null && newImageAssetPath == null && newImageNetworkUrl != null));

    Tuple5<FwdStaticMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget, Map<String, dynamic>, LatLng>?
        oldStaticMarker;

    if (_staticMarkers.keys.contains(markerId)) {
      oldStaticMarker = _staticMarkers[markerId];
    }

    if (oldStaticMarker != null) {
      FwdStaticMarker? newFwdStaticMarker;

      Map<String, dynamic> oldGeoJson = oldStaticMarker.item4;

      Map<String, dynamic> newGeoJson = oldGeoJson;

      if (newCoordinate != null) {
        await animateMarker(
          markerId: markerId,
          newLatLng: newCoordinate,
          duration: const Duration(seconds: 0),
        );
        newGeoJson = FwdGeoJsonHelper.pointGeoJson(
          staticMarkerId: markerId,
          bearing: FwdGeoJsonHelper.pointBearingFromGeoJson(oldGeoJson),
          geometry: newCoordinate,
        );

        await _maplibreMapController.setGeoJsonSource(
          FwdGeoJsonHelper.pointGeoJsonSourceId(markerId),
          newGeoJson,
        );
      }

      if (newBearing != null) {
        (newGeoJson["features"] as List).first["properties"]["bearing"] = newBearing;
        await _maplibreMapController.setGeoJsonSource(
          FwdGeoJsonHelper.pointGeoJsonSourceId(markerId),
          newGeoJson,
        );
      }
      if (newWidgetChild != null) {
        newFwdStaticMarker = await FwdStaticMarker.fromWidget(
          id: markerId,
          coordinate: newCoordinate ?? oldStaticMarker.item5,
          onTap: oldStaticMarker.item1.onTap,
          child: newWidgetChild,
          creatingImageDelay: updatingImageDelay,
          cacheKey: cacheKey,
          anchor: newAnchor ?? MarkerAnchor.center,
        );
      }
      if (newImageAssetPath != null) {
        newFwdStaticMarker = await FwdStaticMarker.fromImageAsset(
          id: markerId,
          coordinate: newCoordinate ?? oldStaticMarker.item5,
          onTap: oldStaticMarker.item1.onTap,
          imageAssetPath: newImageAssetPath,
          anchor: newAnchor ?? MarkerAnchor.center,
        );
      }
      if (newImageNetworkUrl != null) {
        newFwdStaticMarker = await FwdStaticMarker.fromImageNetwork(
          id: markerId,
          coordinate: newCoordinate ?? oldStaticMarker.item5,
          onTap: oldStaticMarker.item1.onTap,
          imageUrl: newImageNetworkUrl,
          anchor: newAnchor ?? MarkerAnchor.center,
        );
      }

      if (newFwdStaticMarker != null) {
        await _maplibreMapController.addImage(
          FwdGeoJsonHelper.getImageId(markerId),
          newFwdStaticMarker.bytes,
        );

        await _maplibreMapController.setGeoJsonSource(
          FwdGeoJsonHelper.pointGeoJsonSourceId(markerId),
          newGeoJson,
        );

        FwdMarkerAnimationWidget fwdStaticMarkerAnimationWidget = FwdMarkerAnimationWidget.fromGeoJson(
          geoJson: newGeoJson,
          maplibreMapController: _maplibreMapController,
          fwdMarkerAnimationController: oldStaticMarker.item2,
          rotate: newFwdStaticMarker.rotate,
          initialBearing: newBearing ?? oldStaticMarker.item1.bearing,
          key: oldStaticMarker.item3.key,
        );

        _staticMarkers[markerId] = Tuple5(
          newFwdStaticMarker,
          oldStaticMarker.item2,
          fwdStaticMarkerAnimationWidget,
          newGeoJson,
          oldStaticMarker.item5,
        );
        final Map<FwdId, FwdMarkerAnimationWidget> animationWidgetsForCallback = {};

        _staticMarkers.forEach((fwdId, tuple4) {
          animationWidgetsForCallback[fwdId] = tuple4.item3;
        });

        _updateStaticMarkerAnimationWidgetsCallback(animationWidgetsForCallback);
      }
    }
  }

  Future<void> addDynamicMarker(FwdDynamicMarker fwdDynamicMarker) async {
    FwdMarkerAnimationController fwdMarkerAnimationController = FwdMarkerAnimationController();
    Point initialPosistion = await _maplibreMapController.toScreenLocation(fwdDynamicMarker.initialCoordinate);
    final fwdMarkerAnimationWidget = FwdMarkerAnimationWidget.fromDynamicMarker(
      fwdDynamicMarker: fwdDynamicMarker,
      maplibreMapController: _maplibreMapController,
      fwdMarkerAnimationController: fwdMarkerAnimationController,
      initialMarkerPosition: initialPosistion,
      rotate: fwdDynamicMarker.rotate,
      initialBearing: fwdDynamicMarker.bearing,
      key: UniqueKey(),
    );
    _dynamicMarkers[fwdDynamicMarker.id] = Tuple4(
      fwdDynamicMarker,
      fwdMarkerAnimationController,
      fwdMarkerAnimationWidget,
      fwdDynamicMarker.initialCoordinate,
    );
    final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
    _dynamicMarkers.forEach((fwdId, tuple4) {
      dynamicMarkerAnimationWidgetsForCallback[fwdId] = tuple4.item3;
    });
    _updateDynamicMarkerWidgetsCallback(dynamicMarkerAnimationWidgetsForCallback);
  }

  Future<void> updateDynamicMarker({
    required FwdId markerId,
    LatLng? newCoordinate,
    Function(FwdId, LatLng, Point<num>?)? newOnMarkerTap,
    Widget? newChild,
  }) async {
    Tuple4<FwdDynamicMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget, LatLng>? oldDynamicMarker;

    if (_dynamicMarkers.keys.contains(markerId)) {
      oldDynamicMarker = _dynamicMarkers[markerId];
    }

    if (oldDynamicMarker != null) {
      FwdDynamicMarker? newFwdDynamicMarker;
      Point? newInitialMarkerPosition;

      if (newCoordinate != null) {
        await animateMarker(
          markerId: markerId,
          newLatLng: newCoordinate,
          duration: const Duration(seconds: 0),
        );
        newInitialMarkerPosition = await toScreenLocation(newCoordinate);
      }

      if (newChild != null || newOnMarkerTap != null) {
        newFwdDynamicMarker = FwdDynamicMarker(
          id: markerId,
          initialCoordinate: newCoordinate ?? oldDynamicMarker.item4,
          onMarkerTap: newOnMarkerTap ?? oldDynamicMarker.item1.onMarkerTap,
          child: newChild ?? oldDynamicMarker.item1.child,
        );
      }

      final fwdMarkerAnimationWidget = FwdMarkerAnimationWidget.fromDynamicMarker(
        fwdDynamicMarker: newFwdDynamicMarker ?? oldDynamicMarker.item1,
        maplibreMapController: _maplibreMapController,
        fwdMarkerAnimationController: oldDynamicMarker.item2,
        initialMarkerPosition: newInitialMarkerPosition ?? oldDynamicMarker.item3.initialMarkerPosition,
        rotate: newFwdDynamicMarker?.rotate ?? oldDynamicMarker.item1.rotate,
        initialBearing: newFwdDynamicMarker?.bearing ?? oldDynamicMarker.item1.bearing,
        key: oldDynamicMarker.item3.key,
      );

      _dynamicMarkers[markerId] = Tuple4(
        newFwdDynamicMarker ?? oldDynamicMarker.item1,
        oldDynamicMarker.item2,
        fwdMarkerAnimationWidget,
        newCoordinate ?? oldDynamicMarker.item4,
      );
      //
      //  коллбэк
      final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
      _dynamicMarkers.forEach((fwdId, tuple4) {
        dynamicMarkerAnimationWidgetsForCallback[fwdId] = tuple4.item3;
      });
      _updateDynamicMarkerWidgetsCallback(dynamicMarkerAnimationWidgetsForCallback);
    }
  }

  Future<void> updatePolyline(FwdId fwdId, Color color) async {
    if (_polylines.keys.contains(fwdId)) {
      await _maplibreMapController.updateLine(
        _polylines[fwdId]!.item2,
        LineOptions(
          lineColor: color.toHexStringRGB(),
        ),
      );
    }
  }

  Future<void> updatePolygon(FwdId fwdId, Color color) async {
    if (_polygons.keys.contains(fwdId)) {
      await Future.wait(
        [
          _maplibreMapController.updateFill(
            _polygons[fwdId]!.item2,
            FillOptions(
              fillOutlineColor: color.toHexStringRGB(),
              fillColor: color.withOpacity(0.2).toHexStringRGB(),
            ),
          ),
          _maplibreMapController.updateLine(
            _polygons[fwdId]!.item3,
            LineOptions(
              lineColor: color.toHexStringRGB(),
            ),
          ),
        ],
      );
    }
  }

  Future<void> _deletePolylineById(FwdId fwdId) async {
    if (_polylines.keys.contains(fwdId)) {
      await _maplibreMapController.removeLine(_polylines[fwdId]!.item2);
      _polylines.remove(fwdId);
    }
  }

  Future<void> _deletePolygonById(FwdId fwdId) async {
    if (_polygons.keys.contains(fwdId)) {
      await _maplibreMapController.removeFill(_polygons[fwdId]!.item2);
      await _maplibreMapController.removeLine(_polygons[fwdId]!.item3);
      _polygons.remove(fwdId);
    }
  }

  Future<void> _deleteStaticMarkerById(FwdId fwdId) async {
    if (_staticMarkers.keys.contains(fwdId)) {
      await _maplibreMapController.removeLayer(FwdGeoJsonHelper.symbolLayerId(fwdId));
      await _maplibreMapController.removeSource(FwdGeoJsonHelper.pointGeoJsonSourceId(fwdId));
      _staticMarkers.remove(fwdId);
    }
  }

  Future<void> deleteById(FwdId fwdId) async {
    if (_staticMarkers.keys.contains(fwdId)) {
      await _maplibreMapController.removeLayer(FwdGeoJsonHelper.symbolLayerId(fwdId));
      await _maplibreMapController.removeSource(FwdGeoJsonHelper.pointGeoJsonSourceId(fwdId));
      _staticMarkers.remove(fwdId);
    }
    if (_dynamicMarkers.keys.contains(fwdId)) {
      _dynamicMarkers.removeWhere((id, widget) => id == fwdId);
      final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
      _dynamicMarkers.forEach((id, tuple4) => dynamicMarkerAnimationWidgetsForCallback[id] = tuple4.item3);
      _updateDynamicMarkerWidgetsCallback(dynamicMarkerAnimationWidgetsForCallback);
    }
    if (_polylines.keys.contains(fwdId)) {
      await _deletePolylineById(fwdId);
    }
    if (_polygons.keys.contains(fwdId)) {
      await _deletePolygonById(fwdId);
    }
  }

  Future<void> clearMap() async {
    // clear all static markers
    _staticMarkers.forEach((fwdId, tuple) async {
      await _maplibreMapController.removeLayer(FwdGeoJsonHelper.symbolLayerId(fwdId));
      await _maplibreMapController.removeSource(FwdGeoJsonHelper.pointGeoJsonSourceId(fwdId));
    });
    _staticMarkers.clear();
    _updateStaticMarkerAnimationWidgetsCallback(<FwdId, FwdMarkerAnimationWidget>{});
    //

    // clear all dynamic markers
    _dynamicMarkers.clear();
    _updateDynamicMarkerWidgetsCallback(<FwdId, FwdMarkerAnimationWidget>{});
    //

    // clear all polylines
    _polylines.forEach((fwdId, tuple) async {
      await _deletePolylineById(fwdId);
    });
    _polylines.clear();
    //

    // clear all polygons (polygon is a fruit of love of fill and line)

    _polygons.forEach((fwdId, tuple) async {
      await _maplibreMapController.removeFill(tuple.item2);
      await _maplibreMapController.removeLine(tuple.item3);
    });
    _polygons.clear();
    //
  }

  Future<void> animateMarker({
    required FwdId markerId,
    required LatLng newLatLng,
    required Duration duration,
  }) async {
    if (_staticMarkers.keys.contains(markerId)) {
      // Обновляем маркер, чтобы хранить последнюю координату маркера в мапе
      final staticMarkerNewLatLng = Tuple5(
        _staticMarkers[markerId]!.item1,
        _staticMarkers[markerId]!.item2,
        _staticMarkers[markerId]!.item3,
        FwdGeoJsonHelper.pointGeoJson(
          staticMarkerId: markerId,
          bearing: _staticMarkers[markerId]!.item1.bearing,
          geometry: newLatLng,
        ),
        newLatLng,
      );
      _staticMarkers[markerId] = staticMarkerNewLatLng;
      _staticMarkers[markerId]?.item2.animate(point: newLatLng, duration: duration);
    }
    if (_dynamicMarkers.keys.contains(markerId)) {
      // Обновляем маркер, чтобы хранить последнюю координату маркера в мапе
      final dynamicMarkerNewLatLng = Tuple4(
        _dynamicMarkers[markerId]!.item1,
        _dynamicMarkers[markerId]!.item2,
        _dynamicMarkers[markerId]!.item3,
        newLatLng,
      );
      _dynamicMarkers[markerId] = dynamicMarkerNewLatLng;
      _dynamicMarkers[markerId]?.item2.animate(point: newLatLng, duration: duration);
    }
  }

  Future<void> addPolyline(FwdPolyline fwdPolyline) async {
    await _deletePolylineById(fwdPolyline.id);

    final line = await _maplibreMapController.addLine(
      LineOptions(
        geometry: fwdPolyline.geometry,
        lineWidth: fwdPolyline.thickness,
        lineColor: fwdPolyline.color?.toHexStringRGB(),
        lineOpacity: fwdPolyline.color?.opacity,
      ),
      <dynamic, dynamic>{
        'id': FwdGeoJsonHelper.lineGeoJsonSourceId(fwdPolyline.id),
      },
    );

    _polylines[fwdPolyline.id] = Tuple2(fwdPolyline, line);
  }

  Future<void> addPolygon(FwdPolygon fwdPolygon) async {
    await _deletePolygonById(fwdPolygon.id);

    final fill = await _maplibreMapController.addFill(
      FillOptions(
        fillColor: fwdPolygon.fillColor?.toHexStringRGB(),
        fillOutlineColor: fwdPolygon.borderColor?.toHexStringRGB(),
        geometry: fwdPolygon.geometry,
        fillOpacity: 0.2,
      ),
      <dynamic, dynamic>{
        'id': FwdGeoJsonHelper.fillGeoJsonSourceId(fwdPolygon.id),
      },
    );
    final line = await _maplibreMapController.addLine(
      LineOptions(
        geometry: fwdPolygon.geometry.first,
        lineWidth: 3,
        lineColor: fwdPolygon.borderColor?.toHexStringRGB(),
      ),
      <dynamic, dynamic>{
        'id': FwdGeoJsonHelper.lineGeoJsonSourceId(fwdPolygon.id),
      },
    );

    _polygons[fwdPolygon.id] = Tuple3(fwdPolygon, fill, line);
  }

  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await _maplibreMapController.toScreenLocation(latLng);
  }

  Future<LatLng?> getUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    LatLng? latLng;

    try {
      locationData = await location.getLocation();
      latLng = LatLng(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      return null;
    }
    return latLng;
  }

  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await _maplibreMapController.moveCamera(cameraUpdate);
  }

  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    Duration? duration,
  }) async {
    await _maplibreMapController.animateCamera(cameraUpdate, duration: duration);
  }
}
