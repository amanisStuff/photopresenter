import 'package:flutter/material.dart';
import '../../shared/theme.dart';

class RetroSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const RetroSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = const Color(0xFF2E5CB8),
  });

  @override
  Widget build(BuildContext context) {
    const animDuration = Duration(milliseconds: 200);
    const animCurve = Curves.easeOutCubic;

    final leftRaised = !value;
    final rightRaised = value;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 48,
          height: 24,
          child: Row(
            children: [
              Expanded(child: _RockerHalf(
                raised: leftRaised,
                activeColor: activeColor,
                duration: animDuration,
                curve: animCurve,
              )),
              Container(
                width: 1.5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF202030), Color(0xFF404050)],
                  ),
                ),
              ),
              Expanded(child: _RockerHalf(
                raised: rightRaised,
                activeColor: activeColor,
                duration: animDuration,
                curve: animCurve,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RockerHalf extends StatelessWidget {
  final bool raised;
  final Color activeColor;
  final Duration duration;
  final Curve curve;

  const _RockerHalf({
    required this.raised,
    required this.activeColor,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: BoxDecoration(
        gradient: raised
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.surfaceLightest, AppTheme.surfaceMuted],
              )
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(const Color(0xFF505068), activeColor, 0.12)!,
                  Color.lerp(const Color(0xFF606078), activeColor, 0.08)!,
                ],
              ),
        border: raised
            ? Border(
                top: BorderSide(color: AppTheme.surfaceLightest, width: 1),
                left: BorderSide(color: AppTheme.surfaceLightest, width: 1),
                bottom: const BorderSide(color: Color(0xFF606060), width: 1),
                right: const BorderSide(color: Color(0xFF606060), width: 1),
              )
            : Border(
                top: BorderSide(color: Color.lerp(const Color(0xFF303048), activeColor, 0.1)!, width: 1),
                left: BorderSide(color: Color.lerp(const Color(0xFF303048), activeColor, 0.1)!, width: 1),
                bottom: const BorderSide(color: Color(0xFF505068), width: 1),
                right: const BorderSide(color: Color(0xFF505068), width: 1),
              ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textOnDarkSubtle.withValues(alpha: raised ? 0.35 : 0.0),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}