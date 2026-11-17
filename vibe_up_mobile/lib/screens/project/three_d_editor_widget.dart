import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A modular 3D interior design editor widget powered by Three.js via WebView.
///
/// Communicates with the embedded JS scene through a bidirectional bridge:
///  - Flutter → JS: [addFurniture], [removeSelected], [rotateSelected], [clearAll], etc.
///  - JS → Flutter: events via the [FlutterChannel] JavaScriptChannel
class ThreeDEditorWidget extends StatefulWidget {
  final void Function(Map<String, dynamic> event)? onSceneEvent;

  const ThreeDEditorWidget({super.key, this.onSceneEvent});

  @override
  State<ThreeDEditorWidget> createState() => ThreeDEditorWidgetState();
}

class ThreeDEditorWidgetState extends State<ThreeDEditorWidget> {
  late final WebViewController _controller;
  bool _isReady = false;

  // Completers for capture requests
  Completer<String?>? _capture3DCompleter;
  Completer<String?>? _captureTopViewCompleter;
  Completer<String?>? _sceneDataCompleter;
  Completer<String?>? _glbCompleter;
  Completer<String?>? _vrSceneCompleter;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1A1A2E))
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            final event = data['event'];

            // Handle capture responses
            if (event == 'capture3d' && _capture3DCompleter != null) {
              _capture3DCompleter!.complete(data['image']);
              _capture3DCompleter = null;
            } else if (event == 'captureTopView' && _captureTopViewCompleter != null) {
              _captureTopViewCompleter!.complete(data['image']);
              _captureTopViewCompleter = null;
            } else if (event == 'sceneData' && _sceneDataCompleter != null) {
              _sceneDataCompleter!.complete(jsonEncode(data));
              _sceneDataCompleter = null;
            } else if (event == 'exportGLB' && _glbCompleter != null) {
              _glbCompleter!.complete(data['glbBase64']);
              _glbCompleter = null;
            } else if (event == 'vrSceneData' && _vrSceneCompleter != null) {
              _vrSceneCompleter!.complete(jsonEncode(data));
              _vrSceneCompleter = null;
            } else if (event == 'ready') {
              if (mounted) setState(() => _isReady = true);
            }

            widget.onSceneEvent?.call(data);
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isReady = true);
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/3d_editor.html');
  }

  // ─── Public API ───

  /// Add a furniture item with optional name & price metadata.
  void addFurniture(String type, {String? name, double? price}) {
    final n = _sanitize(name ?? '');
    final p = price ?? 0;
    _runJS("addFurniture('${_sanitize(type)}', '$n', $p)");
  }

  /// Add furniture at a relative position (0-1 range for x, z).
  void addFurnitureAt(String type, double relX, double relZ, {String? name, double? price}) {
    final n = _sanitize(name ?? '');
    final p = price ?? 0;
    _runJS("addFurnitureAt('${_sanitize(type)}', $relX, $relZ, '$n', $p)");
  }

  void removeSelected() => _runJS('removeSelected()');

  void rotateSelected(double angle) => _runJS('rotateSelected($angle)');

  void clearAll() => _runJS('clearAll()');

  void resetCamera() => _runJS('resetCamera()');

  void setCameraMode(String mode) => _runJS("setCameraMode('$mode')");

  void fitRoomInView() => _runJS('fitRoomInView()');

  void showDropZone(bool show) => _runJS('showDropZone(${show ? "true" : "false"})');

  /// Capture the current 3D perspective view as a base64 data URL.
  Future<String?> capture3DView() {
    _capture3DCompleter = Completer<String?>();
    _runJS('capture3DView()');
    return _capture3DCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  /// Capture a 2D top-down view of the room as a base64 data URL.
  Future<String?> captureTopView() {
    _captureTopViewCompleter = Completer<String?>();
    _runJS('captureTopView()');
    return _captureTopViewCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  /// Get the full scene data (placed items with positions, rotations, prices).
  Future<String?> getSceneData() {
    _sceneDataCompleter = Completer<String?>();
    _runJS('getSceneData()');
    return _sceneDataCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  void sendCommand(Map<String, dynamic> cmd) {
    _runJS("executeFromFlutter('${_sanitize(jsonEncode(cmd))}')");
  }

  /// Export the full scene as a GLB binary (base64 encoded).
  Future<String?> exportGLB() {
    _glbCompleter = Completer<String?>();
    _runJS('exportGLB()');
    return _glbCompleter!.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => null,
    );
  }

  /// Serialize the scene into a Unity-compatible JSON payload.
  /// Includes full position {x,y,z}, rotation {x,y,z}, scale {x,y,z}, and room dimensions.
  Future<String?> serializeSceneForVR() {
    _vrSceneCompleter = Completer<String?>();
    _runJS('serializeSceneForVR()');
    return _vrSceneCompleter!.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  // ─── Internals ───

  void _runJS(String js) {
    if (_isReady) {
      _controller.runJavaScript(js);
    }
  }

  String _sanitize(String input) {
    return input.replaceAll("'", "\\'").replaceAll('\n', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (!_isReady)
            Container(
              color: const Color(0xFF1A1A2E),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                    SizedBox(height: 16),
                    Text(
                      'Loading 3D Editor…',
                      style: TextStyle(color: Color(0xFFFF6B6B), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
