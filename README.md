# Flutter Map Gesture Drawing 

[![pub package](https://img.shields.io/pub/v/flutter_map_gesture_drawing.svg)](https://pub.dev/packages/flutter_map_gesture_drawing)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Flutter package for gesture-based loop drawing on interactive maps using touch gestures. Perfect for real estate applications.

## 📱 Screenshots

### Manually Closed Loop
<img src="https://user-images.githubusercontent.com/your-username/manually-closed-loop.png" alt="Manually closed loop drawing" width="300"/>

*User draws a path and manually closes the loop by connecting back to the starting point*

### Automatically Closed Loop  
<img src="https://user-images.githubusercontent.com/your-username/automatically-closed-loop.png" alt="Automatically closed loop drawing" width="300"/>

*System automatically closes the loop when user finishes drawing gesture*

## 🏠 Perfect for Real Estate

- **Area Selection**: Define search areas and regions of interest
- **Location Marking**: Mark and outline specific geographical areas
- **Interactive Maps**: Built on flutter_map for reliable map functionality

## ✨ Features

### Core Functionality
- **Touch-based Drawing**: Finger drawing on map surfaces
- **Real-time Feedback**: Visual updates as you draw
- **Large Area Optimization**: Optimized for large area selection (minimum 1km between points)
- **Tap vs Drag Detection**: Prevents accidental loops from single taps

### Map Integration  
- **Flutter Map Integration**: Built on the robust flutter_map package
- **OpenStreetMap Support**: Uses OpenStreetMap tiles by default
- **Coordinate Conversion**: Seamless screen-to-geographic coordinate mapping
- **Map State Management**: Proper handling of map interactions during drawing
- **Disabled Map Interactions**: Drawing gestures take priority during active drawing

### User Experience
- **Clean Interface**: Minimal UI focused on drawing functionality  
- **Clear Action**: One-tap clear button to reset drawings
- **Loading States**: Visual feedback during map initialization
- **Gesture Priority**: Drawing gestures take precedence over map pan/zoom

## 🚀 Getting Started

### Prerequisites

- Flutter 3.8.1 or higher
- Dart SDK compatible with Flutter version

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_map_gesture_drawing: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## 📱 Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map_gesture_drawing/flutter_map_gesture_drawing.dart';

class AreaSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Area')),
      body: DrawingMap(),
    );
  }
}
```

### Advanced Usage with Custom Controller

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map_gesture_drawing/flutter_map_gesture_drawing.dart';

class CustomPropertyMap extends StatefulWidget {
  @override
  _CustomPropertyMapState createState() => _CustomPropertyMapState();
}

class _CustomPropertyMapState extends State<CustomPropertyMap> {
  final DrawingController _controller = DrawingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDrawingChanged);
  }

  void _onDrawingChanged() {
    if (_controller.drawingState.isCompleted) {
      // Handle completed loop
      final loop = _controller.drawingState.currentPath;
      print('Loop completed with ${loop.length} points');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Define Area'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveArea,
          ),
        ],
      ),
      body: DrawingMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.clearLoop(),
        child: Icon(Icons.clear),
      ),
    );
  }

  void _saveArea() {
    if (_controller.drawingState.hasPoints) {
      // Save the loop
      final points = _controller.drawingState.currentPath;
      // Your save logic here
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Working with Drawing States

```dart
// Check drawing status
if (controller.drawingState.isDrawing) {
  print('Currently drawing loop');
}

if (controller.drawingState.isCompleted) {
  print('Loop completed');
}

if (controller.drawingState.hasPoints) {
  final pointCount = controller.drawingState.currentPath.length;
  print('Loop has $pointCount points');
}

// Access the drawn path
final List<LatLng> loopPoints = controller.drawingState.currentPath;

// Check if loop is closed
if (controller.drawingState.isLoopClosed) {
  print('Loop is complete');
}
```

## 📊 API Reference

### DrawingMap Widget

The main widget that provides the interactive map with drawing capabilities.

```dart
DrawingMap({
  Key? key,
})
```

**Features:**
- Interactive map with OpenStreetMap tiles
- Touch gesture detection for drawing
- Automatic map state management
- Built-in clear functionality

### DrawingController

Controls the drawing state and manages the drawn path.

```dart
final controller = DrawingController();
```

**Key Methods:**
- `startDrawing(LatLng point)` - Begin drawing at specified point
- `addPoint(LatLng point)` - Add point to current path  
- `completeDrawing()` - Finish and close the current drawing
- `clearLoop()` - Clear current drawing and reset state

**Properties:**
- `drawingState` - Current state of the drawing
- `mapController` - Flutter map controller instance
- `isMapReady` - Whether map is initialized and ready

### DrawingState

Represents the current state of a drawing operation.

```dart
enum DrawingStatus { idle, drawing, completed }

class DrawingState {
  final DrawingStatus status;
  final List<LatLng> currentPath;
  final bool isLoopClosed;
  final DateTime? startTime;
}
```

**Helpful Getters:**
- `isIdle` - No active drawing
- `isDrawing` - Currently in drawing mode  
- `isCompleted` - Drawing finished
- `hasPoints` - Has at least one point in path

## 🎯 Real Estate Use Cases

- Draw areas of interest
- Create custom search regions
- Define service areas
- Mark zones and neighborhoods


## 🔧 Technical Implementation

### Gesture Detection Pattern

The package uses a wrapper pattern around FlutterMap:

```dart
GestureDetector(
  onPanStart: _onPanStart,
  onPanUpdate: _onPanUpdate, 
  onPanEnd: _onPanEnd,
  child: FlutterMap(
    options: MapOptions(
      interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
    ),
  ),
)
```

### Coordinate Conversion

Seamless conversion between screen coordinates and geographic coordinates:

```dart
LatLng? screenToLatLng(Offset screenPosition, MapController mapController, BuildContext context) {
  final mapState = mapController.camera;
  return mapState.offsetToCrs(screenPosition);
}
```

### Tap vs Drag Detection

Prevents accidental loop creation from single taps:

```dart
void _onPanEnd(DragEndDetails details) {
  if (!_isDragging) {
    // Was tap - reset to idle
    return;
  }
  // Was drag - close loop
}
```

## 🔗 Dependencies

```yaml
dependencies:
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
```

- **flutter_map**: Map widget, MapController, PolylineLayer, coordinate system
- **latlong2**: LatLng class, distance calculations, geographic utilities

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Issues and Support

- **Bug Reports**: [GitHub Issues](https://github.com/your-username/flutter_map_gesture_drawing/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/your-username/flutter_map_gesture_drawing/discussions)
- **Documentation**: [API Documentation](https://pub.dev/documentation/flutter_map_gesture_drawing)

## 📚 Additional Resources

- [Flutter Map Documentation](https://docs.fleaflet.dev/)
- [LatLng Package](https://pub.dev/packages/latlong2)
- [OpenStreetMap](https://www.openstreetmap.org/)

---

Built with ❤️ for the Flutter community and real estate professionals.
