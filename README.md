# Lorien

Lorien is an **infinite canvas drawing/note-taking app that is focused on performance, small savefiles and simplicity**. It's not based on bitmap images like Krita, Gimp or Photoshop; it rather saves brush strokes as a collection of points and renders the image at runtime (kind of like SVG). It's primarily desinged to be used as a digital notebook and as brainstorming tool. While it can totally be used to make small sketches, it is not meant to replace traditional art programs that operate on bitmap images. It is entirely written in the [Godot Game Engine](https://godotengine.org/). For an overview on how to use Lorien have a look [here](docs/manual.md). 

**This is very much a WIP and still a bit rough around the edges**. The savefile format *might* also change in the future (see [Roadmap](docs/roadmap.md)). Contributions (be it bug reports, code or art) are very welcome; have a look at the [Contributing guide](docs/contributing.md).

![Lorien demo](https://drive.google.com/uc?export=view&id=18m6AY4cgUUWbiGm7mdg6a71oNTvLi2df)

## Features
- Infinite canvas
- Infinite undo/redo
- (Almost) Infinite zoom
- High performance
- Extremly small savefiles ([File format specs](docs/file_format.md))
- Work on multiple documents simultaneously
- Tools: Freehand brush, line brush, eraser, color picker
- Support for pressure sensitivity & drawing tablets (Wacom, etc.)
- Runs on Windows, Linux & Mac

## Non-Features
- Opacity
- Layers (can maybe be added later)
- Multiple brushes