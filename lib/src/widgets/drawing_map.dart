import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/drawing_controller.dart';
import '../utils/geometry_utils.dart';
import 'offline_banner.dart';

/// A stateful widget that displays an interactive map with drawing capabilities.
///
/// This widget combines a Flutter Map with gesture detection to allow users
/// to draw loops by touching and dragging on the map surface. It manages
/// the drawing state through a [DrawingController] and renders the current
/// drawing path as a polyline overlay on the map.
///
/// Features:
/// * Touch-based drawing on map surface
/// * Automatic loop closure when drawing completes
/// * Real-time visual feedback during drawing
/// * Clear button to reset the current drawing
/// * Disabled map interactions during drawing to prevent conflicts
///
/// Example usage:
/// ```dart
/// Scaffold(
///   body: DrawingMap(),
/// )
/// ```
class DrawingMap extends StatefulWidget {

  const DrawingMap({
    super.key,
  });

  @override
  State<DrawingMap> createState() => _DrawingMapState();
}

class _DrawingMapState extends State<DrawingMap> {
  final DrawingController _drawingController = DrawingController();
  bool _isOfflineMode = false;    // Local widget state for offline mode UI
  bool _showOfflineBanner = false;
  Timer? _loadingTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _drawingController.addListener(() {
      if (_drawingController.isMapReady) {
        _loadingTimeoutTimer?.cancel();
      }
      setState(() {});
    });
    
    // STARTS: Connection Attempt Mode (0-10 seconds timeout)
    _loadingTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_drawingController.isMapReady && mounted) {
        setState(() {
          _isOfflineMode = true;      // SWITCHES TO: Offline Mode
          _showOfflineBanner = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _loadingTimeoutTimer?.cancel();
    _drawingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // OFFLINE MODE: Show red banner
          if (_showOfflineBanner)
            MapOfflineBanner(
              backgroundColor: Colors.blue.withValues(alpha: 0.3),
              onRetry: _onRetryConnection,
              isDismissible: true,
              onDismiss: () {
                setState(() {
                  _showOfflineBanner = false;
                });
              },
            ),
          // Main map area
          Expanded(
            child: Stack(
              children: [
                _isOfflineMode
                    // ? const PlaceholderMap()
                ? _buildFlutterMap()
                    : GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: _buildFlutterMap(),
                      ),
                // CONNECTION ATTEMPT MODE: Show blue loading indicator 
                if (!_drawingController.isMapReady && !_isOfflineMode)
                // if (!_drawingController.isMapReady && _drawingController.isOffline)
                  Container(
                    color: Colors.blue.withValues(alpha: 0.3),
                    child: const Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // ONLINE MODE: Show floating action button (hidden in offline mode)
      floatingActionButton: _isOfflineMode ? null : FloatingActionButton(
        tooltip: "Clean the loop",
        onPressed: () {
          _drawingController.clearLoop();
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.touch_app_outlined, size: 48.0),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final latLng = GeometryUtils.screenToLatLng(details.localPosition, _drawingController.mapController, context); // Starting a new drawing path
    if (latLng == null) return;

    _drawingController.startDrawing(latLng);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_drawingController.drawingState.isDrawing) {
      final latLng = GeometryUtils.screenToLatLng(details.localPosition, _drawingController.mapController, context); // Adding points to existing path
      if (latLng == null) return;

      _drawingController.addPoint(latLng);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_drawingController.drawingState.isDrawing) {
      _drawingController.completeDrawing();
    }
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: _drawingController.mapController,
      options: MapOptions(
        initialCenter: LatLng(51.509364, -0.128928),
        initialZoom: 9.2,
        onMapReady: _drawingController.setMapReady,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.github.kotrotko.flutter_map_gesture_drawing',
        ),
        PolylineLayer(
          polylines: [
            if (_drawingController.drawingState.hasPoints)
              Polyline(
                points: _drawingController.drawingState.isLoopClosed
                    ? [..._drawingController.drawingState.currentPath, _drawingController.drawingState.currentPath.first]
                    : _drawingController.drawingState.currentPath,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
          ],
        ),
      ],
    );
  }

  void _onRetryConnection() {
    setState(() {
      _isOfflineMode = false;
      _showOfflineBanner = false;
    });
    
    // Restart the timeout timer
    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_drawingController.isMapReady && mounted) {
        setState(() {
          _isOfflineMode = true;
          _showOfflineBanner = true;
        });
      }
    });
  }
}
