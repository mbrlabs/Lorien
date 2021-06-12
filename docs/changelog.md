# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.3.0] - Unreleased

### Added
- Infinite grid
- The selection tool can now also deselect seperate brush strokes by holding down shift
- "Save as" functionality to save a file as a new file with a new file name, while keeping the original
- Implemented "Open" and "Save" functionality in menu
- Translations: Spanish

### Fixed
- Fixed camera position & zoom getting reset when switching between tabs

### Changed
- Disabled VSync and set the fixed target FPS to 144, which results in much smoother brush strokes and a better feeling on low Hz monitors
- Lower the FPS to 10 if the window is unfocused to reduce the CPU/GPU load and save energy
- Improved camera zoom
- Switched to GLES3 backend

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

[0.3.0]: https://github.com/mbrlabs/lorien/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/mbrlabs/lorien/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/mbrlabs/lorien/releases/tag/v0.1.0