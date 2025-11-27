import 'package:latlong2/latlong.dart';

/// Represents the current status of a drawing operation.
///
/// The drawing process follows a simple lifecycle:
/// * [idle] - No active drawing, ready to start
/// * [drawing] - Currently capturing user input
/// * [completed] - Drawing finished, loop closed
enum DrawingStatus {
  /// No drawing is in progress, controller is ready for new input
  idle,
  /// User is actively drawing, points are being captured
  drawing,
  /// Drawing is finished and the loop has been closed
  completed,
}

/// Immutable state object that represents the current drawing session.
///
/// This class holds all information about an active or completed drawing,
/// including the path coordinates, timing, and closure status. It uses
/// immutable patterns with [copyWith] for state updates.
///
/// Example usage:
/// ```dart
/// // Create initial state
/// var state = DrawingState.idle();
///
/// // Start drawing
/// state = state.copyWith(
///   status: DrawingStatus.drawing,
///   currentPath: [LatLng(51.5, -0.1)],
///   startTime: DateTime.now(),
/// );
///
/// // Add points
/// state = state.copyWith(
///   currentPath: [...state.currentPath, newPoint],
/// );
/// ```
class DrawingState {
  /// Current status of the drawing operation
  final DrawingStatus status;
  /// List of geographic coordinates forming the drawing path
  final List<LatLng> currentPath;
  /// Timestamp when drawing began, null if not started
  final DateTime? startTime;
  /// Whether the drawing loop has been automatically closed
  final bool isLoopClosed;
  
  const DrawingState({
    required this.status,
    required this.currentPath,
    this.startTime,
    this.isLoopClosed = false,
  });
  
  DrawingState.idle() : this(
    status: DrawingStatus.idle,
    currentPath: const [],
    startTime: null,
    isLoopClosed: false,
  );
  
  /// Returns true if the drawing is currently in progress.
  bool get isDrawing => status == DrawingStatus.drawing;
  
  /// Returns true if no drawing is in progress and ready to start.
  bool get isIdle => status == DrawingStatus.idle;
  
  /// Returns true if the current path contains at least one point.
  bool get hasPoints => currentPath.isNotEmpty;
  
  /// Creates a new [DrawingState] with updated values.
  ///
  /// Only the provided parameters will be updated, all others remain unchanged.
  /// This follows the immutable state pattern for safe state management.
  DrawingState copyWith({
    DrawingStatus? status,
    List<LatLng>? currentPath,
    DateTime? startTime,
    bool? isLoopClosed,
  }) {
    return DrawingState(
      status: status ?? this.status,
      currentPath: currentPath ?? this.currentPath,
      startTime: startTime ?? this.startTime,
      isLoopClosed: isLoopClosed ?? this.isLoopClosed,
    );
  }
}