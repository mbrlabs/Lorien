extends Node

# -------------------------------------------------------------------------------------------------
# Note:
#
# This code is taken from: https://github.com/godot-extended-libraries/godot-antialiased-line2d
# which has been released under the MIT license
# -------------------------------------------------------------------------------------------------

# Generates the antialiased Line2D texture that will be used by the various nodes.
# We do this in a singleton to perform this generation once at load, rather than once
# for every AntialiasedLine2D node. This generation can take several dozen milliseconds,
# so it would cause stuttering if performed during gameplay.

var texture := ImageTexture.new()

func _ready() -> void:
	# Generate a texture with custom mipmaps (1-pixel feather on the top and bottom sides).
	# The texture must be square for mipmaps to work correctly. The texture's in-memory size is still
	# pretty low (less than 200 KB), so this should not cause any performance problems.
	var data := PackedByteArray()
	for mipmap in [256, 128, 64, 32, 16, 8, 4, 2, 1]:
		for y in mipmap:
			for x in mipmap:
				# White. If you need a different color for the Line2D, change the `default_color` property.
				data.push_back(255)

				# The last two mips are very thin. They require special handling to prevent lines
				# from disappearing entirely.
				if mipmap >= 4:
					if y == 0 or y == mipmap - 1:
						# Fully transparent.
						data.push_back(0)
					else:
						# Fully opaque.
						data.push_back(255)
				elif mipmap == 2:
					# Line will be a bit misaligned, but it'll look smoother than using lower alpha
					# for both pixels.
					if y == 1:
						# Fully transparent.
						data.push_back(0)
					else:
						# Fully opaque.
						data.push_back(255)
				else: # mipmap == 1
					# Average of 0 and 255 (there is only one pixel).
					data.push_back(128)

	var image := Image.new()
	image.create_from_data(256, 256, true, Image.FORMAT_LA8, data)
	texture.create_from_image(image)
