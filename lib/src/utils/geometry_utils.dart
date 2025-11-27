import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Utility class providing geometric calculations and coordinate transformations.
///
/// This class contains static methods for working with geographic coordinates,
/// screen coordinates, and geometric operations commonly needed in map applications.
class GeometryUtils {
  /// Converts a screen coordinate to a geographic coordinate (LatLng).
  ///
  /// Takes a screen [screenPosition] and converts it to the corresponding
  /// geographic coordinate using the current map state from [mapController].
  ///
  /// Returns null if the conversion fails.
  static LatLng? screenToLatLng(
    Offset screenPosition,
    MapController mapController,
    BuildContext context,
  ) {
    try {
      final mapState = mapController.camera;
      return mapState.offsetToCrs(screenPosition);
    } catch (e) {
      return null;
    }
  }
  
  /// Converts a list of screen coordinates to geographic coordinates.
  ///
  /// Transforms multiple [screenPoints] to LatLng coordinates, filtering out
  /// any failed conversions. For visualising of drawing paths.
  static List<LatLng> screenPointsToLatLngs(
    List<Offset> screenPoints,
    MapController mapController,
    BuildContext context,
  ) {
    return screenPoints
        .map((point) => screenToLatLng(point, mapController, context))
        .where((latLng) => latLng != null)
        .cast<LatLng>()
        .toList();
  }
  
  /// Note: No latLngToScreen method is provided in this utility class.
  ///
  /// FlutterMap automatically handles LatLng-to-screen coordinate conversion
  /// for all standard map overlays (Polyline, Polygon, Marker, etc.).
  /// Manual conversion is unnecessary for typical map drawing applications
  /// since the framework manages rendering and coordinate transformations
  /// internally when displaying geographic data on the map canvas.

  /// Calculates the distance between two geographic points for drawing validation.
  ///
  /// Used by DrawingController to enforce minimum 1km spacing between consecutive
  /// drawing points and validate loop closure distances. Returns distance in meters
  /// using the haversine formula for accuracy over the Earth's surface.
  static double calculateDistance(LatLng point1, LatLng point2) {
    const distance = Distance();
    return distance.as(LengthUnit.Meter, point1, point2);
  }
  
  /// Determines if a point lies within a polygon using ray casting algorithm.
  ///
  /// Uses the ray casting algorithm to check if [point] is inside the [polygon].
  /// Returns false if the polygon has fewer than 3 vertices.
  ///
  /// The algorithm works by casting a ray from the point to infinity and counting
  /// intersections with polygon edges. Odd count means inside, even means outside.
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      final j = (i + 1) % polygon.length;
      
      if (_rayIntersectsSegment(point, polygon[i], polygon[j])) {
        intersections++;
      }
    }
    
    return intersections % 2 == 1;
  }
  
  /// Helper method to determine if a horizontal ray intersects a line segment.
  ///
  /// Used internally by [isPointInPolygon] to implement the ray casting algorithm.
  /// Checks if a horizontal ray cast eastward from [point] intersects the
  /// line segment from [segStart] to [segEnd].
  static bool _rayIntersectsSegment(LatLng point, LatLng segStart, LatLng segEnd) {
    if (segStart.latitude > point.latitude == segEnd.latitude > point.latitude) {
      return false;
    }
    
    final intersectionLng = (segEnd.longitude - segStart.longitude) *
            (point.latitude - segStart.latitude) /
            (segEnd.latitude - segStart.latitude) +
        segStart.longitude;
    
    return point.longitude < intersectionLng;
  }
}