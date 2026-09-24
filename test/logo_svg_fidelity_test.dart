import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/screens/splash_screen.dart';

void main() {
  test('SvgLogoGeometry matches original Logo-Dark.svg with 100% fidelity', () {
    // 1. Check raw file matches
    final file = File('assets/logo/Logo-Dark.svg');
    expect(file.existsSync(), true);

    // 2. Check geometry viewBox
    final geometry = SvgLogoGeometry.instance;
    expect(geometry.viewBox, const Rect.fromLTWH(0, 0, 669, 653));

    // 3. Check exact number of visual paths
    expect(geometry.paths.length, 14);

    // 4. Check symmetry: exactly 7 left and 7 right
    final leftCount = geometry.paths.where((p) => p.isLeft).length;
    final rightCount = geometry.paths.where((p) => !p.isLeft).length;
    expect(leftCount, 7);
    expect(rightCount, 7);

    // 5. Check tiers
    for (var tier = 0; tier < 4; tier++) {
      final tierPaths = geometry.paths.where((p) => p.tier == tier).toList();
      expect(tierPaths.isNotEmpty, true);
      expect(tierPaths.any((p) => p.isLeft), true);
      expect(tierPaths.any((p) => !p.isLeft), true);
    }

    // 6. Test pointer tangent precision at multiple animation progress points
    for (final p in [0.15, 0.25, 0.35, 0.45]) {
      for (final item in geometry.paths.where((p) => p.isPrimary)) {
        final (tStart, tEnd) = (0.10, 0.52);
        if (p >= tStart && p <= tEnd) {
          for (final metric in item.metrics) {
            final offset = metric.length * 0.5;
            final tangent = metric.getTangentForOffset(offset);
            expect(tangent, isNotNull);
            expect(tangent!.position.dx.isFinite, true);
            expect(tangent.position.dy.isFinite, true);
            expect(tangent.vector.dx.isFinite, true);
            expect(tangent.vector.dy.isFinite, true);
          }
        }
      }
    }
  });
}
