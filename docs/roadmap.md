# Roadmap

This file provides an overview of the direction this project is heading. There is no timeline attached to milestones, because i don't know much i'm going to work on this in the future and how much people are willing to help.

## Milestone 1 - Basic functionality and stability
There are still a lot of placeholders in the program. While i did my best to implement as much features as possible before i made the project public, there is still a lot to do. This is a list of features which i would expect from a program like this (and which are not implemented yet):

- Basic shape tools (rectangle, line, maybe a circle/oval)
- Color picker tool (picks colors from brush strokes on the canvas)
- Persist last opened projects, so you don't have to reopen files between program restarts
- Different themes (at least 1 dark and 1 light theme)
- Cleanup UI
- More settings (max zoom level, zoom speed, min/max brush size etc.)
- Improvements to project tabs (currently custom ui; maybe replace with Godot's `Tabs` to take advantage of scrolling and reordering)
- Improve the brush stroke filter and optimizer
- Improve zooming
- `Save as` functionality
- Stability across all platforms + bugfixing
- Stabilize savefile format (can still change later (before 1.0) but hopefully not as much)
- Improve the logo. I'm actually pretty proud of myself for the current logo, but i'm sure it can be improved. It's supposed to be a leaf by the way ;)
- Maybe setup unit tests? I have never done that in Godot, but it's worth checking out early on in the project
- etc.

## Milestone 2 - Improve rendering & performance

### The problem 
For the first iteration of the project i used Godot's built-in Line2D to render the brush stokes. Because of this built-in functionality i had a working prototype ready in less then a day. Line2D basically has everything i need:

- Renders lines of (almost) arbitrary length
- Variable width through the use of a Curve (useful for pressure sensitivity)
- Different colors
- Can do anti-aliasing (not ideal though; more on this later)
- Can leverage Godot's 2D batch rendering system for performance

But there are also some issues:
- Out of the 2 anti-aliasing methods provided none work perfectly:
	1. Line2D's `antialiased` property uses an OpenGL hint to draw smooth edges. OpenGL drivers are not required to implement hints, and in fact most don't, so it may work on my machine but not on yours. If it works, it looks really nice, but it's also pretty slow compared to the other method.
	
	2. Line2D has the ability to fill the rendered line with a texture. If you make a texture in a way that the edges have very low opacity, you can fake anti-aliasing. This is pretty fast and works on every system, but it looks kind of bad when you zoom in really far. This can maybe worked around with by switching between different textures based on the camera zoom level, but it's not ideal either.

- Using Line2D's `width_curve` for drawing pressure sensitive lines is kind of wonky (the line literally wobbles when it's very long (only while still drawing; i.e. adding points))

### Solution 1: GDNative plugin or custom module
Implement a custom system for:   
- Line meshing (can reuse a modified version of Godot's LineBuilder which is used internally by Line2D). This should fix the `width_curve` wonkiness.
- Line rendering with custom static batching; also use the VisualServer directly (should improve performance by a lot)
- Anti aliasing. Have to research different AA algorithms and see how feasable it is to implement them in Godot 
- Streaming brush strokes in/out based on view frustrum insead of keeping Line2D nodes in scene tree?

### Solution 2: ?
Something simpler than going native would be nice.


## Milestone 3 - More features (all optional)
- Implement a selection tool to select and move multiples strokes. 
- Implement a brush stabilizer (can optionally be enabled for the brush tool)
- Color palettes / list of previously used colors
- Export functionality (png, jpg, svg)
- A grid
- Layers (pretty sure i'm NOT going to implement this, because you don't even have opacity (by design) and you can just create a new `.lorien` file instead)
- A ruler
- etc.