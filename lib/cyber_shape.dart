import 'package:flutter/material.dart';
import 'dart:math' as math;

enum BorderType {
  rounded,
  beveled,
}

ShapeBorder buildCyberBorderOutline({
  Color color = Colors.white,
  double radius = 10,
  double thickness = 1.2,
}) {
  return CyberBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    ),
    //borderRadius: BorderRadius.circular(11),
    bottomLeft: BorderType.rounded,
    side: BorderSide(
      color: color,
      width: thickness,
    ),
  );
}

ShapeBorder buildCyberBorder({
  double radius = 10,
}) {
  return CyberBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    ),
    bottomLeft: BorderType.rounded,
  );
}

class CyberBorder extends ShapeBorder {
  /// Creates a rounded rectangle border.
  ///
  /// The arguments must not be null.
  const CyberBorder({
    this.side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  })  : assert(side != null),
        assert(borderRadius != null);

  final BorderSide side;

  /// The radii for each corner.
  final BorderRadiusGeometry borderRadius;

  final BorderType topLeft;
  final BorderType topRight;
  final BorderType bottomLeft;
  final BorderType bottomRight;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(side.width);
  }

  @override
  ShapeBorder scale(double t) {
    return CyberBorder(
      side: side.scale(t),
      borderRadius: borderRadius * t,
      topLeft: topLeft,
      topRight: topRight,
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getCyberPath(
      borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width),
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      topLeft: topLeft,
      topRight: topRight,
    );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return getCyberPath(
      borderRadius.resolve(textDirection).toRRect(rect),
      bottomLeft: bottomLeft,
      bottomRight: bottomRight,
      topLeft: topLeft,
      topRight: topRight,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    if (rect.isEmpty) return;
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final Path path = getOuterPath(rect, textDirection: textDirection)
          ..addPath(
              getInnerPath(rect, textDirection: textDirection), Offset.zero);
        canvas.drawPath(path, side.toPaint());
        break;
    }
    return;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CyberBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomLeft == bottomLeft &&
        other.bottomRight == bottomRight;
  }

  @override
  int get hashCode => hashValues(side, borderRadius);
}

Path getCyberPath(
  RRect rrect, {
  BorderType topLeft,
  BorderType topRight,
  BorderType bottomLeft,
  BorderType bottomRight,
}) {
  final Offset centerLeft = Offset(rrect.left, rrect.center.dy);
  final Offset centerRight = Offset(rrect.right, rrect.center.dy);
  final Offset centerTop = Offset(rrect.center.dx, rrect.top);
  final Offset centerBottom = Offset(rrect.center.dx, rrect.bottom);

  Path path = Path();
  for (var i = 0; i < 4; i++) {
    Offset o1, o2;
    if (i == 0) {
      // top left
      final double tlRadiusX = math.max(0.0, rrect.tlRadiusX);
      final double tlRadiusY = math.max(0.0, rrect.tlRadiusY);
      o1 = Offset(rrect.left, math.min(centerLeft.dy, rrect.top + tlRadiusY));
      o2 = Offset(math.min(centerTop.dx, rrect.left + tlRadiusX), rrect.top);
    } else if (i == 1) {
      // top right
      final double trRadiusX = math.max(0.0, rrect.trRadiusX);
      final double trRadiusY = math.max(0.0, rrect.trRadiusY);
      o1 = Offset(math.max(centerTop.dx, rrect.right - trRadiusX), rrect.top);
      o2 = Offset(rrect.right, math.min(centerRight.dy, rrect.top + trRadiusY));
    } else if (i == 2) {
      // bottom right
      final double brRadiusX = math.max(0.0, rrect.brRadiusX);
      final double brRadiusY = math.max(0.0, rrect.brRadiusY);
      o1 = Offset(
          rrect.right, math.max(centerRight.dy, rrect.bottom - brRadiusY));
      o2 = Offset(
          math.max(centerBottom.dx, rrect.right - brRadiusX), rrect.bottom);
    } else {
      // bottom left
      final double blRadiusX = math.max(0.0, rrect.blRadiusX);
      final double blRadiusY = math.max(0.0, rrect.blRadiusY);
      o1 = Offset(
          math.min(centerBottom.dx, rrect.left + blRadiusX), rrect.bottom);
      o2 =
          Offset(rrect.left, math.max(centerLeft.dy, rrect.bottom - blRadiusY));
    }

    if (i == 0) {
      path.moveTo(o1.dx, o1.dy);
    } else {
      path.lineTo(o1.dx, o1.dy);
    }

    Radius radius;
    BorderType borderType;
    if (i == 0) {
      radius = rrect.tlRadius;
      borderType = topLeft;
    } else if (i == 1) {
      radius = rrect.trRadius;
      borderType = topRight;
    } else if (i == 2) {
      radius = rrect.brRadius;
      borderType = bottomRight;
    } else {
      radius = rrect.blRadius;
      borderType = bottomLeft;
    }

    if (borderType == BorderType.rounded) {
      path.arcToPoint(o2, radius: radius);
    } else {
      path.lineTo(o2.dx, o2.dy);
    }
  }
  path.close();
  return path;
}
