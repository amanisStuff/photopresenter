import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  Future<void> toggleFullScreen() async {
    bool isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }

  Future<void> enterFocusMode() async {
    await windowManager.setFullScreen(true);
    await windowManager.setAsFrameless();
  }

  Future<void> exitFocusMode() async {
    await windowManager.setFullScreen(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
  }

  Future<void> minimize() async {
    await windowManager.minimize();
  }

  Future<void> close() async {
    await windowManager.close();
  }
}
