import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final randomGenerator = Random();
final contentHeight = <double>[];
void main() {
  for (int i = 0; i < 20; ++i) {
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

  MasonGridDelegate({required this.contentHeight, required this.contentWidth});

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final count = max(constraints.crossAxisExtent ~/ contentWidth, 2);

    return MasonGridLayout(
      contentHeight: contentHeight,
      crossAxisCount: count,
      maxCrossAxisExtent: min(
        contentWidth,
        constraints.crossAxisExtent / count,
      ),
      viewportHeight: constraints.viewportMainAxisExtent,
    );
  }

  @override
  bool shouldRelayout(MasonGridDelegate oldDelegate) =>
      oldDelegate.contentHeight != contentHeight ||
      oldDelegate.contentWidth != contentWidth;
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
    _childHeightPositions = <double>[];
    for (int i = 0; i < crossAxisCount; ++i) {
      _childHeightPositions.add(0);
    }
    for (int i = crossAxisCount; i < crossAxisCount * 2; ++i) {
      _childHeightPositions.add(contentHeight[i - crossAxisCount]);
    }

    for (int i = crossAxisCount * 2; i < contentHeight.length; ++i) {
      _childHeightPositions.add(
        contentHeight[i - crossAxisCount] +
            _childHeightPositions[i - crossAxisCount],
      );
    }
  }

  late final List<double> _childHeightPositions;

  @override
  double computeMaxScrollOffset(int childCount) {
    double maxHeight = 0;
    for (int i = 1; i <= crossAxisCount; ++i) {
      final length = _childHeightPositions.length;
      maxHeight = max(
        maxHeight,
        _childHeightPositions[length - i] + contentHeight[length - i],
      );
    }
    maxHeight += 16;

    return maxHeight;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final childGeometry = SliverGridGeometry(
      scrollOffset: _childHeightPositions[index],
      crossAxisOffset: (index % crossAxisCount) * maxCrossAxisExtent,
      mainAxisExtent: contentHeight[index],
      crossAxisExtent: maxCrossAxisExtent,
    );
    return childGeometry;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return min(
      _getMaxIndexForScroll(scrollOffset + viewportHeight * 1.25) +
          crossAxisCount,
      contentHeight.length - 1,
    );
  }

  int _getMaxIndexForScroll(double scrollOffset) {
    int lastIndex = 0;
    // TODO(NLU): убрать перебор списка
    while (lastIndex < contentHeight.length &&
        scrollOffset > _childHeightPositions[lastIndex]) {
      lastIndex++;
    }

    return lastIndex + lastIndex % crossAxisCount;
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    return max(
      _getMaxIndexForScroll(scrollOffset - viewportHeight / 2) - crossAxisCount,
      0,
    );
  }
}
