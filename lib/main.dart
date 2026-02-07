import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final randomGenerator = Random();
final contentHeight = <double>[];
void main() {
  for (int i = 0; i < 200; ++i) {
    contentHeight.add(randomGenerator.nextDouble() * 300 + 250);
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CardsPage());
  }
}

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
          child: GridView.builder(
            itemCount: contentHeight.length,
            gridDelegate: MasonGridDelegate(
              contentHeight: contentHeight,
              contentWidth: 250,
            ),
            itemBuilder: (_, index) =>
                MasonTile(height: contentHeight[index], index: index),
          ),
        ),
      ),
    );
  }
}

class MasonTile extends StatelessWidget {
  final double height;
  final int index;
  const MasonTile({super.key, required this.height, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      elevation: 8,
      child: SizedBox(
        height: height,
        child: Center(
          child: Text(
            '$index',
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class MasonGridDelegate extends SliverGridDelegate {
  final List<double> contentHeight;
  final double contentWidth;

  SliverGridLayout? _grid;

  MasonGridDelegate({required this.contentHeight, required this.contentWidth});

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final screenWidth = constraints.crossAxisExtent;
    final count = max(screenWidth ~/ contentWidth, 2);
    final actualWidth = (screenWidth - contentWidth * count) / count + contentWidth;
    _grid ??= MasonGridLayout(
      contentHeight: contentHeight,
      crossAxisCount: count,
      maxCrossAxisExtent: 
        actualWidth,
      viewportHeight: constraints.viewportMainAxisExtent,
    );

    return _grid!;
  }

  @override
  bool shouldRelayout(MasonGridDelegate oldDelegate) {
    final relayout =
        oldDelegate.contentHeight != contentHeight ||
        oldDelegate.contentWidth != contentWidth;
    if (relayout) _grid = null;
    return relayout;
  }
}

class MasonGridLayout extends SliverGridLayout {
  final List<double> contentHeight;
  final int crossAxisCount;
  final double maxCrossAxisExtent;
  final double viewportHeight;

  MasonGridLayout({
    required this.contentHeight,
    required this.crossAxisCount,
    required this.maxCrossAxisExtent,
    required this.viewportHeight,
  }) {
    _columnHeights = List.generate(crossAxisCount, (i) => 0.0, growable: false);
  }

  late final List<double> _columnHeights;
  final List<_GridPosition> _childPositions = [];

  @override
  double computeMaxScrollOffset(int childCount) {
    return _columnHeights.reduce(max);
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    if (index >= _childPositions.length) {
      final columnIndex = _columnHeights.indexOf(_columnHeights.reduce(min));
      final scrollOffset = _columnHeights[columnIndex];
      _columnHeights[columnIndex] += contentHeight[index];

      _childPositions.add(
        _GridPosition(column: columnIndex, scrollOffset: scrollOffset),
      );
    }

    final scrollOffset = _childPositions[index].scrollOffset;
    final columnIndex = _childPositions[index].column;

    final childGeometry = SliverGridGeometry(
      scrollOffset: scrollOffset,
      crossAxisOffset: columnIndex * maxCrossAxisExtent,
      mainAxisExtent: contentHeight[index],
      crossAxisExtent: maxCrossAxisExtent,
    );

    return childGeometry;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    if (_childPositions.isEmpty) return 6;
    return min(
      _getMaxIndexForScroll(scrollOffset) + crossAxisCount,
      contentHeight.length - 1,
    );
  }

  int _getMaxIndexForScroll(double scrollOffset) {
    final lastIndex = _childPositions.lastIndexWhere(
      (el) => el.scrollOffset < scrollOffset,
    );

    return lastIndex;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) =>
      max(_getMaxIndexForScroll(scrollOffset - viewportHeight / 2), 0);
}

class _GridPosition {
  final int column;
  final double scrollOffset;

  _GridPosition({required this.column, required this.scrollOffset});
}
