import 'package:maplibre_gl/maplibre_gl.dart';

import '../fwd_id/fwd_id.dart';

class FwdGeoJsonHelper {
  // imageId

  static String getImageId(FwdId markerId) => "${markerId.parseToString()}_image";

  // geoJsonSourceId

  static String pointGeoJsonSourceId(FwdId markerId) => "${markerId.parseToString()}_pointGeoJsonSource";
  static String lineGeoJsonSourceId(FwdId markerId) => "${markerId.parseToString()}_lineGeoJsonSource";
  static String fillGeoJsonSourceId(FwdId markerId) => "${markerId.parseToString()}_fillGeoJsonSource";

  // layerId

  static String symbolLayerId(FwdId markerId) => "${markerId.parseToString()}_symbolLayer";
  static String lineLayerId(FwdId markerId) => "${markerId.parseToString()}_polylineLayer";
  static String fillLayerId(FwdId markerId) => "${markerId.parseToString()}_polygonLayer";

  // featureId

  static String pointFeatureId(FwdId markerId) => "${markerId.parseToString()}_pointFeature";
  static String lineFeatureId(FwdId markerId) => "${markerId.parseToString()}_lineFeature";
  static String fillFeatureId(FwdId markerId) => "${markerId.parseToString()}_fillFeature";

  static FwdId markerIdFromPointFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().replaceFirst('_pointFeature', ''));

  static FwdId markerIdFromPolylineFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().replaceFirst('_lineFeature', ''));

  static FwdId markerIdFromPolygonFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().replaceFirst('_fillFeature', ''));

  // toGeoJson

  static Map<String, dynamic> pointGeoJson({
    required FwdId staticMarkerId,
    required double bearing,
    required LatLng geometry,
  }) {
    final Map<String, dynamic> geoJson = <String, dynamic>{
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": pointFeatureId(staticMarkerId),
          "properties": {
            "bearing": bearing,
            "fwdId": staticMarkerId.parseToString(),
          },
          "geometry": {
            "type": "Point",
            "coordinates": [geometry.longitude, geometry.latitude],
          }
        },
      ]
    };
    return geoJson;
  }

  static Map<String, dynamic> lineGeoJson({
    required FwdId polylineId,
    required List<LatLng> geometry,
  }) {
    final Map<String, dynamic> geoJson = <String, dynamic>{
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": lineFeatureId(polylineId),
          "properties": {
            "fwdId": polylineId.parseToString(),
          },
          "geometry": {
            "type": "LineString",
            "coordinates": [
              for (final point in geometry) [point.longitude, point.latitude],
            ]
          }
        },
      ]
    };
    return geoJson;
  }

  static Map<String, dynamic> fillGeoJson({
    required FwdId polygoneId,
    required List<List<LatLng>> geometry,
  }) {
    final Map<String, dynamic> geoJson = <String, dynamic>{
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": fillFeatureId(polygoneId),
          "properties": {
            "fwdId": polygoneId.parseToString(),
          },
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              for (final point in geometry)
                [
                  for (final sub in point) [sub.longitude, sub.latitude],
                ]
            ]
          }
        },
      ]
    };
    return geoJson;
  }

  // parse geoJson and get props

  static double pointBearingFromGeoJson(Map<String, dynamic> geoJson) =>
      (geoJson["features"] as List).first["properties"]["bearing"] as double;

  static String stringFwdIdFromGeoJson(Map<String, dynamic> geoJson) =>
      (geoJson["features"] as List).first["properties"]["fwdId"].toString();

  static LatLng pointLatLngFromGeoJson(Map<String, dynamic> geoJson) => LatLng(
        ((geoJson["features"] as List).first["geometry"]["coordinates"] as List).last as double,
        ((geoJson["features"] as List).first["geometry"]["coordinates"] as List).first as double,
      );

  static List<LatLng> polylineLatLngsFromGeoJson(Map<String, dynamic> geoJson) => <LatLng>[
        for (final point in ((geoJson["features"] as List).first["geometry"]["coordinates"] as List))
          LatLng(point.last as double, point.first as double)
      ];
}
