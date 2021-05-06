# jabol
Just a bunch of lines

## What this is

This is NOT supposed to be an Art Tool. While it can be used as such it's main focus is digital note taking. It's designed to be fast and easy to use while also keeping the savefiles VERY small. To do this Jabol is not saving individual pixels (like Photoshop, Gimp, Krita, etc.) but lines represened by points in 2D space. Think of it like a lightweight SVG editor. These points form lines wich can then be rendered at runtime. Every stroke you make is one line. Lines will can be saved as text in a text file (good for Git etc. but bigger files) or as binary. Every point has additionally a width associated with it, so we can have pressure sensitive input from drawing tablets. Every line has additionally a color associated with it. 

## Features
- Infinite canvas
- Color chooser
- Color picker
- Zoom/Pan
- Undo/redo
- Save as text file line-by-line or as binary. Both have a *.jabol extension.
- 


## Binary file format
Data is stored as a list of strokes. Strokes have a brush color, a brush size and a number points. Points have x and y value and a pressure value.
Strokes look like this:

0-8		color.r (8 bit)
8-16	color.g (8 bit)
16-24	color.b (8 bit)
24-50 	brush size (16 bit)
50-82   number of points (32 bit)
82-..	points (80 bit each)
	0-32	x position (32 bit)
	32-64 	y position (32 bit)
	64-80	pen pressure (16 bit)