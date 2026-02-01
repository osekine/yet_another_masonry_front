# Custom Masonry Grid for Flutter (RenderSliver-based)

This project is a custom Masonry (Pinterest-like) grid implementation for Flutter, built from scratch using low-level rendering primitives.

The goal of the project is to demonstrate a deep understanding of Flutter’s layout system, particularly:

 - RenderSliver

 - SliverGridDelegate

 - SliverGridLayout

 - Lazy layout and viewport-driven rendering

No third-party masonry packages are used intentionally.

## Motivation

Flutter provides SliverGrid, but it assumes uniform row heights.
Masonry layouts require variable item heights and column-based stacking, which is not supported out of the box.

Instead of relying on existing packages, this project explores how such a layout can be implemented manually using Flutter’s rendering layer.

## Features

 - Custom SliverGridDelegate implementation

 - Column-based Masonry algorithm

 - Lazy geometry calculation (only visible items are laid out)

 - Cached layout data to avoid recomputation on scroll

 - Responsive column count based on available width

 - Proper handling of orientation changes

# Architecture Overview
## High-level flow
```
GridView
 └── SliverGrid
      └── MasonGridDelegate
           └── MasonGridLayout
                ├── columnHeights[]
                └── childPositions[]
```

## Core Concepts
### MasonGridDelegate

Responsibilities:

 - Calculate crossAxisCount based on available width

 - Create and cache MasonGridLayout

- Decide when a relayout is required

The delegate does not perform layout calculations itself.
It only configures and owns the layout instance.

### MasonGridLayout

Responsibilities:

 - Assign each item to the shortest column

 - Compute SliverGridGeometry for each child

 - Cache computed positions

 - Calculate the maximum scroll extent

This class contains all Masonry-specific logic.

## Who This Project Is For

Flutter developers aiming for Middle+ / Senior roles

Engineers preparing for system design or rendering interviews

Anyone interested in Flutter’s low-level layout mechanics

## Disclaimer

This project is for educational and demonstrational purposes.
For production use, a well-tested community package may still be the better choice.