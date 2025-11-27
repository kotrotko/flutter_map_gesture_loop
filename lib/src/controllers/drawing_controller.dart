import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/drawing_state.dart';
import '../utils/geometry_utils.dart';

/// Controller that manages the state and lifecycle of drawing loops on a map.
///
/// This controller handles user gesture input to create closed loops by tracking
/// drawing state, managing the current path of points, and automatically closing
/// loops when drawing is completed. It extends [ChangeNotifier] to notify
/// listeners when the drawing state changes.
///
/// Example usage:
/// ```dart
/// final controller = DrawingController();
/// controller.startDrawing(LatLng(51.5, -0.1));
/// controller.addPoint(LatLng(51.6, -0.2));
/// controller.completeDrawing();
/// ```
class DrawingController extends ChangeNotifier {
  final MapController _mapController = MapController();
  DrawingState _drawingState = DrawingState.idle();
  bool isDragging = false;
  bool _isMapReady = false;  // false = Connection Attempt or Offline Mode; true = Online Mode
  bool _isOffline = false;   // false = Connection Attempt or Online Mode; true = Offline Mode
  Timer? _networkTimeoutTimer;
  /// Network timeout duration in seconds before switching to offline mode
  static const int _networkTimeoutSeconds = 10;

  /// Constructor initializes network timeout detection
  DrawingController() {
    _startNetworkTimeoutDetection();
  }

  // Getters
  MapController get mapController => _mapController;
  DrawingState get drawingState => _drawingState;
  bool get isMapReady => _isMapReady;
  bool get isOffline => _isOffline;

  // Setter
  set drawingState(DrawingState state) {
    _drawingState = state;
    notifyListeners();
  }

  /// Sets map ready state to true and hides loading indicator.
  /// Cancels network timeout since tiles loaded successfully.
  /// SWITCHES TO: Online Mode (isMapReady=true, _isOffline=false)
  void setMapReady(){
    _isMapReady = true;
    _cancelNetworkTimeout();
    notifyListeners();
  }

  // State management methods
  void _updateState(DrawingState newState) {
    _drawingState = newState;
    notifyListeners();
  }

  void resetDrawing() {
    isDragging = false;
    _updateState(DrawingState.idle());
  }

  /// Clears the current drawing and resets the controller to idle state.
  ///
  /// This method removes any existing drawing path, stops the drawing process,
  /// and resets all internal state flags. It's typically called when the user
  /// wants to start over or clear their current work.
  void clearLoop() {
    resetDrawing();
  }

  // Drawing lifecycle methods
  /// Begins a new drawing session with the specified starting point.
  ///
  /// This method initializes a new drawing path, sets the drawing status to active,
  /// and records the start time. It resets the dragging flag to properly detect
  /// tap vs drag gestures.
  ///
  /// Parameters:
  /// * [startPoint] - The geographic coordinate where drawing begins
  void startDrawing(LatLng startPoint) {
    isDragging = false;
    _updateState(DrawingState(
      status: DrawingStatus.drawing,
      currentPath: [startPoint],
      startTime: DateTime.now(),
    ));
  }

  /// Adds a new point to the current drawing path during active drawing.
  ///
  /// This method extends the current path with a new geographic coordinate
  /// and sets the dragging flag to indicate continuous drawing motion.
  /// Points are only added when the controller is in drawing state and when
  /// the new point is at least 1km away from the last point for property search areas.
  ///
  /// Parameters:
  /// * [point] - The geographic coordinate to add to the current path
  void addPoint(LatLng point) {
    if (_drawingState.isDrawing) {
      // Only add point if it's far enough from the last point (1km for property search areas)
      if (_drawingState.currentPath.isNotEmpty) {
        final lastPoint = _drawingState.currentPath.last;
        final distance = GeometryUtils.calculateDistance(lastPoint, point);
        if (distance < 1000.0) return; // Minimum 1 kilometer between points
      }
      
      isDragging = true;
      _updateState(_drawingState.copyWith(
        currentPath: [..._drawingState.currentPath, point],
      ));
    }
  }

  /// Completes the current drawing session and closes the loop.
  ///
  /// This method finalizes the drawing by setting the status to completed
  /// and marking the loop as closed. It handles two scenarios:
  /// - **Tap gesture**: If no dragging occurred, completes the loop if points exist
  /// - **Drag gesture**: Always completes and closes the loop
  ///
  /// The loop is automatically closed by connecting the last point back to the first.
  void completeDrawing() {
    if (_drawingState.isDrawing) {
      if (!isDragging) {
        // Handle tap - close the loop if we have points
        if (_drawingState.currentPath.isNotEmpty) {
          _updateState(_drawingState.copyWith(
            status: DrawingStatus.completed,
            isLoopClosed: true,
          ));
        } else {
          resetDrawing();
        }
        return;
      }
      
      // Always close the loop when drawing finishes
      _updateState(_drawingState.copyWith(
        status: DrawingStatus.completed,
        isLoopClosed: true,
      ));
    }
  }

  // Network timeout detection methods
  /// Starts network timeout detection to switch to offline mode if tiles don't load
  void _startNetworkTimeoutDetection() {
    // Normal mode, start timeout timer
    _networkTimeoutTimer = Timer(
      Duration(seconds: _networkTimeoutSeconds),
      _onNetworkTimeout,
    );
  }

  /// Called when network timeout expires - switches to offline mode
  /// SWITCHES TO: Offline Mode (isMapReady=false, _isOffline=true)
  void _onNetworkTimeout() {
    if (!_isMapReady) {
      _isOffline = true;
      notifyListeners();
    }
  }

  /// Cancels the network timeout timer when tiles load successfully
  void _cancelNetworkTimeout() {
    _networkTimeoutTimer?.cancel();
    _networkTimeoutTimer = null;
  }

  @override
  void dispose() {
    _cancelNetworkTimeout();
    super.dispose();
  }
}