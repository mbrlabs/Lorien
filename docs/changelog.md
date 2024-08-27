# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.7.0] 

### Breaking Changes
- The keybindings fromat is different, so you will need to update them again in case you changed them

### Added
- Setting to disable pressure sensitivity and always draw with a constant brush width
- Translations: Ukrainian, Arabic

### Fixed
- Fixed SVG export for brush strokes that have been moved using the move tool
- Made zooming to the mouse cursor in the canvas more accurate 

### Changed
- Migrated from Godot 3.5.x to Godot 4.3
- UI overhaul
- Improved icon resolution on Windows

## [0.6.0] - 2023-11-06

It's been a while - but here is a another release! Special thanks goes to [@MrApplejuice](https://github.com/MrApplejuice) for adding support for rebindable keyboard shortcuts and [@hansemro](https://github.com/hansemro) for enabling the eraser mode when the pen is inverted!

This will be the last "major" version using Godot 3. After this release i will start porting Lorien to Godot 4.

### Added
- Rebindable keyboard shortcuts
- Use eraser tool while tablet pen is inverted
- Dotted grid pattern; can be changed back to lines (or none at all) in the settings
- Translations: Simplified Chinese, Traditional Chinese

### Fixed
- Fixed blurry interface on some macOS devices
- Fixed invisible cursor in some situations
- Fixed issue where moved brush strokes stayed in their original positions after exporting to SVG
- Fixed not being able to draw simple dots by just clicking/tapping the brush once

### Changed
- Changing the application language does not require a restart now
- Improved translations: Spanish, Brasilian Portuguese
- Improved UI auto scaling, especially for Windows and OSX
- Moved to grid toggle button from the toolbar to the settings
- Removed the canvas background color from the toolbar and moved it to Settings > Canvas Color. The previous setting (Appearance > Default canvas color was removed)
- `.lorien` files do no longer store the canvas background color
- Updated to Godot 3.5.3

## [0.5.0] - 2022-06-12

### Breaking Changes
Version `v0.5` of Lorien features a new SuperEraser, which erases brush strokes as soon as it inserects with them. The previous implementation just painted over new brush strokes, which always had the same color as the background - giving you the illusion of a traditional eraser like in bitmap-based programs (Gimp, Photoshop, etc.). The old implementation has been completely removed in favor of the SuperEraser.
The savefile format did not change. However previously made eraser-strokes will be skipped when loading `.lorien` files. Moreover when saving these files, the eraser-strokes will be permanently lost. 

If you rely on these eraser-strokes: DO NOT UPDATE to this version or BACKUP you `.lorien` files before opening them in the new version.

### Added
- Zooming with CTRL+MMB
- Automatically remembering and auto-opening .lorien files upon exit & launch
- Fullscreen support
- Basic SVG exporter
- Circle/Ellipse tool
- New eraser tool behaviour (SuperEraser): intersecting a brush stroke with the eraser brush removes the entiry brush stroke 
- The window size will be saved and restored across program restarts
- Center the canvas based on current mouse position (shortcut: `SPACE`)
- UI scaling for high-dpi monitors
- Toolbar can be scrolled through when the entire toolbar cannot be shown
- Changing the brush color while having strokes actively selected changes the color of these strokes
- Translations: Turkish, Brazilian Portuguese

### Fixed
- Fixed misplaced color picker after window resize
- Fixed keyboard shortcuts for MacOS

### Changed
- Updated to Godot 3.4.4
- Enabled low-energy mode
- Improved brush stroke antialiasing
- Improved selection tool performance on large documents
- Removed old fake-eraser in favor of new SuperEraser
- Removed rudimentary png export in favor of the new SVG exporter 
- Made the brush stroke optimizer less aggresive, which results in smoother lines at the expense of slightly bigger savefiles
- Increased the default pressure sensitvity from 1.0 to 1.5
- Lowered minimum window size
- Default to rounded brush stoke caps

## [0.4.0] - 2021-10-10

### Added
- Distraction free mode which hides the UI. Can be toggled with TAB
- Color palettes: You can use the built-in palette or create custom palettes yourself
- Easteregg: Pressing F12 spwans a playable character who can walk on the drawn lines
- Rectangle tool: Easily draw rectangular shapes
- Translations: Korean, French

### Fixed
- Issue where the the mouse cursor vanished when switching from annother program to Lorien while a dialog was open
- Some UI elements were not hooked up to the localization system

### Changed
- Updated to Godot 3.3.4
- Lines created with the line tool are now subdivided (more points between start and end point) so that it's easier to select them
- Removed the color picker tool in favour of the new palette system
- Removed the default brush color setting in favour of the new palette system
- UI: subtle rounded corners for most elements 
- UI: replaced some default Godot icons with custom versions
- UI: General polish

## [0.3.0] - 2021-07-23

### Added
- Infinite grid
- Copy-Paste selected brush strokes with CTRL+C/CTRL+V or duplicate in one step with CTRL+D
- The selection tool can now also deselect seperate brush strokes by holding down shift
- "Save as" functionality to save a file as a new file with a new file name, while keeping the original
- Implemented "Open" and "Save" functionality in menu
- Translations: Spanish, Russian
- Open files via drag'n drop from the filesystem
- Open files via cli arguments and "Open with.." functionality on Windows
- Option to set foreground and backgound FPS in the settings menu
- Option to set the line cap in settings menu (flat & round)
- Option to change the pressure sensitivity by a fixed multilpier

### Fixed
- Fixed camera position & zoom getting reset when switching between tabs
- Fixed an issue where a brush stroke disappeared if it got too long (See: [#26](https://github.com/mbrlabs/Lorien/issues/26))
- Use default canvas color from settings for newly opened tabs
- Fixed wrong pen pressure display in status bar
- Wrong scaling of cursors when switching between files
- Fixed issue where the brush tool won't activate when switching from annother program to the unfocused Lorien window

### Changed
- Disabled VSync and set the fixed target FPS to 144, which results in much smoother brush strokes and a better feeling on low Hz monitors
- Lower the FPS to 10 if the window is unfocused to reduce the CPU/GPU load and save energy
- Improved camera zoom
- Switched to GLES3 backend
- Removed unimplemented color-preset ui-elements from colorpickers
- Introduced a minimum window size so it can't be resized to 0 anymore
- The selection tool now selects any brush stroke when at least one stroke point is inside the selection rectangle

## [0.2.0] - 2021-06-03

### Added 
- Mention contributors in the About Dialog
- Improved closing of files with unsaved changes
- Export the whole canvas as PNG image
- Implemented the color picker tool, which let's you pick any color on the canvas
- Selection tool
- Ability to move selected brush strokes
- Ability to delete selected brush strokes with delete key
- Added an option to switch between languages: English, German and Italian
- Line Tool: snap in 15° steps when holding down shift 

### Fixed
- Fixed the size of the drawing area/viewport for [high resolution displays](https://github.com/mbrlabs/Lorien/issues/1)
- Fixed some memory leaks
- Various smaller fixes

### Changed
- Switched to GLES2 for better compability with older hardware
- Improved tooltip styling

## [0.1.0] - 2021-05-23

### Added
- Infinite canvas
- Infinite undo/redo
- (Almost) Infinite zoom
- Extremely small savefiles
- Work on multiple documents simultaneously
- Tools: Freehand brush, eraser, line tool
- You can choose different colors for brush strokes and the canvas background via an easy to use color picker
- Designed to be used with a drawing tablet (Wacom, etc.). It also supports pressure sensitivity
- Runs on Windows, Linux & Mac

[0.6.0]: https://github.com/mbrlabs/lorien/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/mbrlabs/lorien/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/mbrlabs/lorien/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/mbrlabs/lorien/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/mbrlabs/lorien/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/mbrlabs/lorien/releases/tag/v0.1.0
