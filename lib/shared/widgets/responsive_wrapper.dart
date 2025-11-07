import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// 웹 환경에서 최대 너비를 제한하는 래퍼
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool addShadow;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 600.0,
    this.addShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    // 웹이 아니면 그냥 child 반환
    if (!kIsWeb) {
      return child;
    }

    // 웹에서는 최대 너비 제한 + 가운데 정렬 + 그림자
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: addShadow
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                )
              : BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
          child: child,
        ),
      ),
    );
  }
}
