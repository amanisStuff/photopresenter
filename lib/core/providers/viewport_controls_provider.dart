import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ActiveOptionsPanel { none, size, light, camera }

class ViewportControlsState {
  final bool gravityMode;
  final ActiveOptionsPanel activeOptionsPanel;
  final bool sizeLocked;
  final double uniformScale;
  final bool lightHorizontalLocked;
  final bool lightVerticalLocked;
  final bool lightDistanceLocked;
  final double lightHorizontalAngle;
  final double lightVerticalAngle;
  final double lightDistance;
  final double cameraHorizontalAngle;
  final double cameraVerticalAngle;
  final double cameraDistance;
  final double cameraPanX;
  final double cameraPanY;
  final double cameraPanZ;
  final bool cameraPanXLocked;
  final bool cameraPanYLocked;
  final bool cameraPanZLocked;
  final bool cameraHorizontalLocked;
  final bool cameraVerticalLocked;
  final bool cameraDistanceLocked;
  final String objectPath;

  const ViewportControlsState({
    this.gravityMode = false,
    this.activeOptionsPanel = ActiveOptionsPanel.none,
    this.sizeLocked = false,
    this.uniformScale = 1.0,
    this.lightHorizontalLocked = false,
    this.lightVerticalLocked = false,
    this.lightDistanceLocked = false,
    this.lightHorizontalAngle = 0.0,
    this.lightVerticalAngle = 90.0,
    this.lightDistance = 5.0,
    this.cameraHorizontalAngle = 0.0,
    this.cameraVerticalAngle = 30.0,
    this.cameraDistance = 15.0,
    this.cameraPanX = 0.0,
    this.cameraPanY = 0.0,
    this.cameraPanZ = 0.0,
    this.cameraPanXLocked = false,
    this.cameraPanYLocked = false,
    this.cameraPanZLocked = false,
    this.cameraHorizontalLocked = false,
    this.cameraVerticalLocked = false,
    this.cameraDistanceLocked = false,
    this.objectPath = 'assets/cube/cube.obj',
  });

  ViewportControlsState copyWith({
    bool? gravityMode,
    ActiveOptionsPanel? activeOptionsPanel,
    bool? sizeLocked,
    double? uniformScale,
    bool? lightHorizontalLocked,
    bool? lightVerticalLocked,
    bool? lightDistanceLocked,
    double? lightHorizontalAngle,
    double? lightVerticalAngle,
    double? lightDistance,
    double? cameraHorizontalAngle,
    double? cameraVerticalAngle,
    double? cameraDistance,
    double? cameraPanX,
    double? cameraPanY,
    double? cameraPanZ,
    bool? cameraPanXLocked,
    bool? cameraPanYLocked,
    bool? cameraPanZLocked,
    bool? cameraHorizontalLocked,
    bool? cameraVerticalLocked,
    bool? cameraDistanceLocked,
    String? objectPath,
  }) {
    return ViewportControlsState(
      gravityMode: gravityMode ?? this.gravityMode,
      activeOptionsPanel: activeOptionsPanel ?? this.activeOptionsPanel,
      sizeLocked: sizeLocked ?? this.sizeLocked,
      uniformScale: uniformScale ?? this.uniformScale,
      lightHorizontalLocked:
          lightHorizontalLocked ?? this.lightHorizontalLocked,
      lightVerticalLocked: lightVerticalLocked ?? this.lightVerticalLocked,
      lightDistanceLocked: lightDistanceLocked ?? this.lightDistanceLocked,
      lightHorizontalAngle: lightHorizontalAngle ?? this.lightHorizontalAngle,
      lightVerticalAngle: lightVerticalAngle ?? this.lightVerticalAngle,
      lightDistance: lightDistance ?? this.lightDistance,
      cameraHorizontalAngle:
          cameraHorizontalAngle ?? this.cameraHorizontalAngle,
      cameraVerticalAngle: cameraVerticalAngle ?? this.cameraVerticalAngle,
      cameraDistance: cameraDistance ?? this.cameraDistance,
      cameraPanX: cameraPanX ?? this.cameraPanX,
      cameraPanY: cameraPanY ?? this.cameraPanY,
      cameraPanZ: cameraPanZ ?? this.cameraPanZ,
      cameraPanXLocked: cameraPanXLocked ?? this.cameraPanXLocked,
      cameraPanYLocked: cameraPanYLocked ?? this.cameraPanYLocked,
      cameraPanZLocked: cameraPanZLocked ?? this.cameraPanZLocked,
      cameraHorizontalLocked:
          cameraHorizontalLocked ?? this.cameraHorizontalLocked,
      cameraVerticalLocked: cameraVerticalLocked ?? this.cameraVerticalLocked,
      cameraDistanceLocked: cameraDistanceLocked ?? this.cameraDistanceLocked,
      objectPath: objectPath ?? this.objectPath,
    );
  }
}

class ViewportControlsNotifier extends Notifier<ViewportControlsState> {
  @override
  ViewportControlsState build() => const ViewportControlsState();

  void toggleGravity() {
    state = state.copyWith(gravityMode: !state.gravityMode);
  }

  void toggleSizeOptions() {
    state = state.copyWith(
      activeOptionsPanel: state.activeOptionsPanel == ActiveOptionsPanel.size
          ? ActiveOptionsPanel.none
          : ActiveOptionsPanel.size,
    );
  }

  void toggleLightOptions() {
    state = state.copyWith(
      activeOptionsPanel: state.activeOptionsPanel == ActiveOptionsPanel.light
          ? ActiveOptionsPanel.none
          : ActiveOptionsPanel.light,
    );
  }

  void toggleCameraOptions() {
    state = state.copyWith(
      activeOptionsPanel: state.activeOptionsPanel == ActiveOptionsPanel.camera
          ? ActiveOptionsPanel.none
          : ActiveOptionsPanel.camera,
    );
  }

  void toggleSizeLocked() {
    state = state.copyWith(sizeLocked: !state.sizeLocked);
  }

  void setUniformScale(double value) {
    state = state.copyWith(uniformScale: value);
  }

  void toggleHorizontalLocked() {
    state = state.copyWith(lightHorizontalLocked: !state.lightHorizontalLocked);
  }

  void toggleVerticalLocked() {
    state = state.copyWith(lightVerticalLocked: !state.lightVerticalLocked);
  }

  void toggleDistanceLocked() {
    state = state.copyWith(lightDistanceLocked: !state.lightDistanceLocked);
  }

  void setLightHorizontalAngle(double value) {
    state = state.copyWith(lightHorizontalAngle: value);
  }

  void setLightVerticalAngle(double value) {
    state = state.copyWith(lightVerticalAngle: value);
  }

  void setLightDistance(double value) {
    state = state.copyWith(lightDistance: value);
  }

  void setCameraHorizontalAngle(double value) {
    state = state.copyWith(cameraHorizontalAngle: value);
  }

  void setCameraVerticalAngle(double value) {
    state = state.copyWith(cameraVerticalAngle: value);
  }

  void setCameraDistance(double value) {
    state = state.copyWith(cameraDistance: value);
  }

  void setCameraPanX(double value) {
    state = state.copyWith(cameraPanX: value);
  }

  void setCameraPanY(double value) {
    state = state.copyWith(cameraPanY: value);
  }

  void setCameraPanZ(double value) {
    state = state.copyWith(cameraPanZ: value);
  }

  void toggleCameraPanXLocked() {
    state = state.copyWith(cameraPanXLocked: !state.cameraPanXLocked);
  }

  void toggleCameraPanYLocked() {
    state = state.copyWith(cameraPanYLocked: !state.cameraPanYLocked);
  }

  void toggleCameraPanZLocked() {
    state = state.copyWith(cameraPanZLocked: !state.cameraPanZLocked);
  }

  void toggleCameraHorizontalLocked() {
    state = state.copyWith(
      cameraHorizontalLocked: !state.cameraHorizontalLocked,
    );
  }

  void toggleCameraVerticalLocked() {
    state = state.copyWith(cameraVerticalLocked: !state.cameraVerticalLocked);
  }

  void toggleCameraDistanceLocked() {
    state = state.copyWith(cameraDistanceLocked: !state.cameraDistanceLocked);
  }

  void setObjectPath(String path) {
    state = state.copyWith(objectPath: path);
  }
}

final viewportProvider =
    NotifierProvider<ViewportControlsNotifier, ViewportControlsState>(() {
      return ViewportControlsNotifier();
    });
