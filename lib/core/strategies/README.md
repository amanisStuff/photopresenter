# core/strategies/

Strategy pattern implementations for interchangeable behaviour.

- `audio_mode_strategy.dart` — Sealed class with two variants: `AudioDrivenStrategy` (advance on silence) and `TimerDrivenStrategy` (advance on countdown)
- `image_filter_decorator.dart` — Nine filter implementations (None, Grayscale, Sepia, Invert, Bright, High Contrast, Extreme Contrast, Blur, Heavy Blur)
- `strategy_providers.dart` — Returns the active strategy based on `settings.audioMode`
