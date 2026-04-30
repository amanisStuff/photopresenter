import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Service for managing window states, including full-screen and focus modes.
class WindowService {
  /// Initializes the window manager.
  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Toggles full-screen mode.
  Future<void> toggleFullScreen() async {
    bool isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }

  /// Enters "Ultra Focus" mode by hiding title bar and going full-screen.
  Future<void> enterFocusMode() async {
    await windowManager.setFullScreen(true);
    await windowManager.setAsFrameless();
  }

  /// Exits focus mode.
  Future<void> exitFocusMode() async {
    await windowManager.setFullScreen(false);
    // Note: Frameless toggle might require window restart or specific logic depending on platform
    // but for now we focus on full-screen exit.
  }

  /// Minimizes the window.
  Future<void> minimize() async {
    await windowManager.minimize();
  }

  /// Closes the window.
  Future<void> close() async {
    await windowManager.close();
  }
}
