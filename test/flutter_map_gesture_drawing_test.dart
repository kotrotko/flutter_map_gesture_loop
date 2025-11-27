import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map_gesture_drawing/flutter_map_gesture_drawing.dart';

void main() {
  group('DrawingController Tests', () {
    test('drawing lifecycle works', () {
      final controller = DrawingController();
      final startPoint = LatLng(51.5, -0.1);
      
      // Initial state should be idle
      expect(controller.drawingState.status, DrawingStatus.idle);
      expect(controller.drawingState.isIdle, true);
      expect(controller.drawingState.isDrawing, false);
      expect(controller.drawingState.currentPath, isEmpty);
      
      // Start drawing - should transition to drawing state
      controller.startDrawing(startPoint);
      expect(controller.drawingState.status, DrawingStatus.drawing);
      expect(controller.drawingState.isDrawing, true);
      expect(controller.drawingState.isIdle, false);
      expect(controller.drawingState.currentPath, [startPoint]);
      expect(controller.drawingState.startTime, isNotNull);
      
      // Complete drawing - should transition to completed state
      controller.completeDrawing();
      expect(controller.drawingState.status, DrawingStatus.completed);
      expect(controller.drawingState.isDrawing, false);
      expect(controller.drawingState.isLoopClosed, true);
      expect(controller.drawingState.currentPath, [startPoint]);
    });

    test('addPoint ignored when not drawing', () {
      final controller = DrawingController();
      final testPoint = LatLng(52.0, -0.2);
      
      // Initially idle - addPoint should be ignored
      expect(controller.drawingState.status, DrawingStatus.idle);
      expect(controller.drawingState.currentPath, isEmpty);
      
      // Try to add point without starting drawing
      controller.addPoint(testPoint);
      
      // State should remain unchanged - no crash, no points added
      expect(controller.drawingState.status, DrawingStatus.idle);
      expect(controller.drawingState.currentPath, isEmpty);
      expect(controller.drawingState.isDrawing, false);
    });
  });
}
